#!/usr/bin/env bash

# Clean YUM cache
yum -y clean all
# Remove old kernels
package-cleanup --oldkernels --count=1
# Remove no longer required packages and dependencies
yum autoremove
rm -Rf /var/cache/yum
# Synchronize the package index files
yum check-update

# Stop log services for cleanup
systemctl stop syslog.socket
systemctl stop rsyslog.service
service auditd stop

# Clean SSH keys
rm -f /etc/ssh/*key*

# Clean temporary dirs and logs
rm -Rf /tmp/*
rm -Rf /var/tmp/*
find /var/log -type f -exec truncate --size=0 {} \;

# Remove Bash history
unset HISTFILE
rm -f /root/.history
rm -f /root/.bash_history
rm -Rf /root/.ssh/

# Remove answer files
rm -f /root/anaconda-ks.cfg
rm -f /root/original-ks.cfg

# Reset hostname
hostnamectl set-hostname ""

# Remove local machine id to prevent cloned VMs to have the same identity
# machine-id will be generated at boot time
# Thanks to this doc: https://github.com/DanHam/packer-virt-sysprep/blob/master/sysprep-op-machine-id.sh
cat /dev/null > /etc/machine-id
rm -f /var/lib/dbus/machine-id

# Remove network UUID and network configs
for ifcfg in `ls /etc/sysconfig/network-scripts/ifcfg-* |grep -v ifcfg-lo` ; do
    sed -i '/HWADDR/d' $ifcfg
    sed -i "/^UUID/d" $ifcfg
done
rm -f /etc/udev/rules.d/*-persistent-*.rules
rm -f /var/lib/NetworkManager/dhclient-*.lease

# Clean shell history
history -w
history -c

# Generalize (seal) VM
# Same as "/sbin/sys-config" script without poweroff
touch /.unconfigured