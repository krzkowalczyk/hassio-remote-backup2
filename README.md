
# Remote Backup

[![GitHub Release][releases-shield]][releases]
[![GitHub license][license-shield]](LICENSE.md)

> Automatically create Hass.io snapshots to remote server using `SCP` or `SMB` protocol.

> This addon is based on [overkill32/hassio-remote-backup] addon.

<hr>

## Table of Contents

* [About](#about)
* [Installation](#installation)
* [Configuration](#configuration)
* [Example](#example)
* [Changelog & Releases](#changelog)

## <a name='about'></a>About

When the add-on is started the following happens:
1. Crontab backup entry is beeing created according to schedule defined in configuration.
2. Crond starts and takes care of backup script execution.
3. When the right time comes, snapshot are being created locally with a timestamp name, e.g.
*Automatic backup 2018-03-04 04:00*.
4. The snapshot are copied to the specified remote location using `SCP` or `SMB` protocol.
5. The local backup are removed locally again.

_Note_ the filenames of the backup are given by their assigned slug.

## <a name='installation'></a>Installation

1. Copy `remote-backup2` folder into `addons/` directory.
2. In Home-assistant supervisor panelgo to add-on-store and click refresh button.
3. Select addon from `Local Add-Ons section` and click install.

## <a name='configuration'></a>Configuration

|Parameter|Required|Description|
|---------|--------|-----------|
|`ssh`||Ssh remote backup config|
|&nbsp;&nbsp;`host`|No|The hostname/url to the remote server.|
|&nbsp;&nbsp;`port`|No|The port to use to `SCP` on to the server.|
|&nbsp;&nbsp;`user`|No|Username to use for `SCP`.|
|&nbsp;&nbsp;`key`|No|The ssh key to use. Not that it should *NOT* be password protected.|
|`smb`||SMB remote backup config|
|&nbsp;&nbsp;`host`|No|The hostname/url to the remote server.|
|&nbsp;&nbsp;`user`|No|Username to use for `SMB`.|
|&nbsp;&nbsp;`password`|No|The password to use when connection to `SMB` share.|
|`remote_directory`|Yes|The directory to put the backups on the remote server.|
|`zip_password`|No|If set then the backup will be contained in a password protected zip|
|`keep_local_backup`|No|Control how many local backups you want to preserve. Default (`""`) is to keep no local backups created from this addon. If `all` then all loocal backups will be preserved. A positive integer will determine how many of the latest backups will be preserved. Note this will delete other local backups created outside this addon.
|`schedule`|yes|Backup schedule execution in cron format. Ex: `1 1 * * *` (Everyday at 1:01am)|

## <a name='example'></a>Example: daily backups at 4 AM to contoso SMB

_Add-on configuration_:
```yaml
smb:
  host: contoso.corp
  user: contoso
  password: contoso1234
ssh:
  host: ''
  port: 22
  user: ''
  key: []
remote_directory: hassio/backup/
zip_password: ''
keep_local_backup: ''
schedule: 4 0 * * *
```

**Note**: _This is just an example, don't copy and past it! Create your own!_

## <a name='changelog'></a>Changelog & Releases

This repository keeps a [change log](CHANGELOG.md). The format of the log
is based on [Keep a Changelog][keepchangelog].

Releases are based on [Semantic Versioning][semver], and use the format
of ``MAJOR.MINOR.PATCH``. In a nutshell, the version will be incremented
based on the following:

- ``MAJOR``: Incompatible or major changes.
- ``MINOR``: Backwards-compatible new features and enhancements.
- ``PATCH``: Backwards-compatible bugfixes and package updates.

[license-shield]: https://img.shields.io/github/license/krzkowalczyk/hassio-remote-backup2
[releases]: https://github.com/krzkowalczyk/hassio-remote-backup2/releases
[releases-shield]: https://img.shields.io/github/v/release/krzkowalczyk/hassio-remote-backup2

[keepchangelog]: http://keepachangelog.com/en/1.0.0/
[semver]: http://semver.org/spec/v2.0.0.html

[overkill32/hassio-remote-backup]: https://github.com/overkill32/hassio-remote-backup