ARG BUILD_FROM
FROM $BUILD_FROM

# Add env
ENV LANG C.UTF-8

# Setup base
RUN apk add --no-cache jq openssh-client zip

# Hass.io CLI
ARG BUILD_ARCH
# ARG CLI_VERSION
RUN apk add --no-cache curl \
    && curl -Lso /usr/bin/hassio https://github.com/home-assistant/cli/releases/download/4.3.0/ha_${BUILD_ARCH} \
    && chmod a+x /usr/bin/hassio

# Copy data
COPY run.sh backup.sh /
RUN chmod a+x /run.sh /backup.sh

CMD [ "/run.sh" ]

# Build arugments
ARG BUILD_DATE
ARG BUILD_REF
ARG BUILD_VERSION

# Set env version
ENV BUILD_VERSION ${BUILD_VERSION}

# Labels
LABEL \
    io.hass.name="Remote Backup v2" \
    io.hass.description="Automatically create Hass.io snapshots to remote server using `SCP` or `SMB` protocol." \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version=${BUILD_VERSION} \
    maintainer="Krzysztof Kowalczyk <krz.kowalczyk@gmail.com>" \
    org.label-schema.description="Automatically create Hass.io snapshots to remote server using `SCP` or `SMB` protocol." \
    org.label-schema.build-date=${BUILD_DATE} \
    org.label-schema.name="Remote Backup v2" \
    org.label-schema.schema-version="1.0" \
    org.label-schema.usage="https://github.com/krzkowalczyk/hassio-remote-backup2/tree/master/README.md" \
    org.label-schema.vcs-ref=${BUILD_REF} \
    org.label-schema.vcs-url="https://github.com/krzkowalczyk/hassio-remote-backup2" \
    org.label-schema.vendor="Hass.io add-ons by krzkowalczyk"
