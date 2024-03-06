# syntax = docker/dockerfile:latest
FROM python:3.11.5-alpine3.18
LABEL maintainer='github.com/oliverzein'
VOLUME /mnt/source
VOLUME /mnt/borg-repository
VOLUME /root/.borgmatic
VOLUME /etc/borgmatic.d
VOLUME /root/.config/borg
VOLUME /root/.ssh
VOLUME /root/.cache/borg

# Volume for SSH-Host-Keys
VOLUME /sshkeys

RUN apk add --update --no-cache \
    bash \
    bash-completion \
    bash-doc \
    ca-certificates \
    curl \
    findmnt \
    fuse \
    libacl \
    logrotate \
    lz4-libs \
    mariadb-client \
    mariadb-connector-c \
    mongodb-tools \
    openssl1.1-compat \
    postgresql-client \
    sqlite \
    sshfs \
    supercronic \
    tzdata \
    openssh-server \
    && rm -rf \
    /var/cache/apk/* \
    /.cache

COPY --chmod=755 entry.sh /entry.sh
COPY requirements.txt /

RUN python3 -m pip install --no-cache -Ur requirements.txt
RUN borgmatic --bash-completion > /usr/share/bash-completion/completions/borgmatic && echo "source /etc/bash/bash_completion.sh" > /root/.bashrc

# sshd speciifc build steps
COPY ./data/sshd.sh /sshd.sh
COPY ./data/sshd_config /etc/ssh/sshd_config
RUN mkdir /run/sshd && \
    adduser borg -D -s /bin/bash && \
    passwd -u borg

ENTRYPOINT ["/entry.sh"]

# Default SSH-Port for clients
EXPOSE 22