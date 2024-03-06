#!/bin/bash
# setup and start the sshd server

SSH_KEY_DIR=/sshkeys

# Create SSH-Host-Keys on persistent storage, if not exist
echo Processing: SSH-Host-Keys
mkdir -p ${SSH_KEY_DIR}/host 2>/dev/null
echo " * Checking / Preparing SSH Host-Keys..."
for keytype in ed25519 rsa ; do
	if [ ! -f "${SSH_KEY_DIR}/host/ssh_host_${keytype}_key" ] ; then
		echo "  ** Creating SSH Hostkey [${keytype}]..."
		ssh-keygen -q -f "${SSH_KEY_DIR}/host/ssh_host_${keytype}_key" -N '' -t ${keytype}
	fi
done

# change ownership of backup target location
# remote clients will be using the "borg" user to connect
chown -R borg:borg /mnt/borg-repository

# start the ssh daemon
/usr/sbin/sshd