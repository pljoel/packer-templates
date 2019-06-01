#!/usr/bin/env bash

# Clean APT cache
apt-get clean
# Remove old kernels
apt-get autoremove --purge
# Remove no longer required packages and dependencies
apt-get autoremove
# Synchronize the package index files
apt-get update

# Stop services for cleanup
systemctl stop syslog.socket
systemctl stop rsyslog.service

# Clean SSH keys
rm -f /etc/ssh/*key*

# Clean temporary dirs and /var/log
rm -Rf /tmp/*
rm -Rf /var/tmp/*
find /var/log -type f -exec truncate --size=0 {} \;

# Remove Bash history
unset HISTFILE
rm -f /root/.history
rm -f /root/.bash_history
rm -Rf /root/.ssh/

# Reset hostname
hostnamectl set-hostname ""

# Remove local machine id to prevent cloned VMs to have the same identity
# systemd-networkd uses /etc/machine-id (also /var/lib/dbus/machine-id)
# machine-id will be generated at boot time
# Thanks to this doc: https://github.com/DanHam/packer-virt-sysprep/blob/master/sysprep-op-machine-id.sh
cat /dev/null > /etc/machine-id
rm -f /var/lib/dbus/machine-id

# Cleanup shell history
history -w
history -c