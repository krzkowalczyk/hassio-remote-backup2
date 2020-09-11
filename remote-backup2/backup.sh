#!/bin/bash
set -e

CONFIG_PATH=/data/options.json

# parse inputs from options
SSH_HOST=$(jq --raw-output ".ssh.host" $CONFIG_PATH)
SSH_PORT=$(jq --raw-output ".ssh.port" $CONFIG_PATH)
SSH_USER=$(jq --raw-output ".ssh.user" $CONFIG_PATH)
SSH_KEY=$(jq --raw-output ".ssh.key[]" $CONFIG_PATH)
REMOTE_DIRECTORY=$(jq --raw-output ".remote_directory" $CONFIG_PATH)
SNAPSHOT_PASSWORD=$(jq --raw-output '.snapshot_password' $CONFIG_PATH)
KEEP_LOCAL_BACKUP=$(jq --raw-output '.keep_local_backup' $CONFIG_PATH)

SMB_HOST=$(jq --raw-output ".smb.host" $CONFIG_PATH)
SMB_USER=$(jq --raw-output ".smb.user" $CONFIG_PATH)
SMB_PASSWORD=$(jq --raw-output ".smb.password" $CONFIG_PATH)

function add-ssh-key {
    echo "Adding SSH key"
    mkdir -p ~/.ssh
    (
        echo "Host remote"
        echo "    IdentityFile ${HOME}/.ssh/id"
        echo "    HostName ${SSH_HOST}"
        echo "    User ${SSH_USER}"
        echo "    Port ${SSH_PORT}"
        echo "    StrictHostKeyChecking no"
    ) > "${HOME}/.ssh/config"

    while read -r line; do
        echo "$line" >> "${HOME}/.ssh/id"
    done <<< "$SSH_KEY"

    chmod 600 "${HOME}/.ssh/config"
    chmod 600 "${HOME}/.ssh/id"
}

function copy-backup-to-remote-ssh {

    cd /backup/
    echo "Copying ${slug}.tar to ${REMOTE_DIRECTORY} on ${SSH_HOST} using SCP"
    scp -F "${HOME}/.ssh/config" "${slug}.tar" remote:"${REMOTE_DIRECTORY}"

}

function copy-backup-to-remote-smb {

    cd /backup/
    echo "Copying ${slug}.tar to smb://${SMB_HOST}/${REMOTE_DIRECTORY} using curl"
    curl --upload-file "${slug}.tar" -u "${SMB_USER}:${SMB_PASSWORD}" "smb://${SMB_HOST}/${REMOTE_DIRECTORY}"

}

function delete-local-backup {

    hassio snapshots reload

    if [[ ${KEEP_LOCAL_BACKUP} == "all" ]]; then
        :
    elif [[ -z ${KEEP_LOCAL_BACKUP} ]]; then
        echo "Deleting local backup: ${slug}"
        hassio snapshots remove "${slug}"
    else

        last_date_to_keep=$(hassio snapshots list --raw-json | jq .data.snapshots[].date | sort -r | \
            head -n "${KEEP_LOCAL_BACKUP}" | tail -n 1 | xargs date -D "%Y-%m-%dT%T" +%s --date )

        hassio snapshots list --raw-json | jq -c .data.snapshots[] | while read -r backup; do
            if [[ $(echo ${backup} | jq .date | xargs date -D "%Y-%m-%dT%T" +%s --date ) -lt ${last_date_to_keep} ]]; then
                echo "Deleting local backup: $(echo ${backup} | jq -r .slug)"
                hassio snapshots remove "$(echo ${backup} | jq -r .slug)"
            fi
        done

    fi
}

function create-local-backup {
    name="Automated backup $(date +'%Y-%m-%d %H:%M')"
    if [[ -z $SNAPSHOT_PASSWORD  ]]; then
        echo "Creating local backup: \"${name}\""
        slug=$(hassio snapshots new --name="${name}" --raw-json | jq --raw-output '.data.slug')
    else
        echo "Creating local password protected backup: \"${name}\""
        slug=$(hassio snapshots new --name="${name}" --password="${SNAPSHOT_PASSWORD}" --raw-json | jq --raw-output '.data.slug')
    fi
    echo "Backup created: ${slug}"
}

create-local-backup

if [[ "$SSH_KEY" ]] && [[ "$SSH_HOST" ]] && [[ "$SSH_USER" ]]; then
    echo "Copying backup to remote SSH server"
    add-ssh-key
    copy-backup-to-remote-ssh
fi

if [[ "$SMB_HOST" ]] && [[ "$SMB_PASSWORD" ]] && [[ "$SMB_USER" ]]; then
    echo "Copying backup to remote SMB server"
    copy-backup-to-remote-smb
else
    echo "No remote endpoint specified !"
    echo "Unable to send backup to remote location !"
fi

delete-local-backup

echo "Backup process done!"
exit 0
