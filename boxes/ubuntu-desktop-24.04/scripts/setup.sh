#!/bin/bash
set -eux

export DEBIAN_FRONTEND=noninteractive

# Update the repository cache
apt -y update

# Install the dependencies
apt -y install curl

# Allow password-less sudo and disable requiretty
cat > /etc/sudoers.d/vagrant << EOF
Defaults:vagrant !requiretty
vagrant ALL=(ALL) NOPASSWD:ALL
EOF
chmod 440 /etc/sudoers.d/vagrant

# Create the SSH directory
mkdir -p /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh
chown vagrant:vagrant /home/vagrant/.ssh

# Download the Vagrant SSH public keys
curl -fsSL -o /home/vagrant/.ssh/authorized_keys https://raw.githubusercontent.com/hashicorp/vagrant/main/keys/vagrant.pub
chmod 600 /home/vagrant/.ssh/authorized_keys
chown vagrant:vagrant /home/vagrant/.ssh/authorized_keys

# Disable UseDNS in the SSH server configuration
if grep -q -E "^[[:space:]]*UseDNS" /etc/ssh/sshd_config; then
  sed -i "s/^\s*UseDNS.*/UseDNS no/" /etc/ssh/sshd_config
else
  echo "UseDNS no" >> /etc/ssh/sshd_config
fi

# Disable GSSAPIAuthentication in the SSH server configuration
if grep -q -E "^[[:space:]]*GSSAPIAuthentication" /etc/ssh/sshd_config; then
  sed -i "s/^\s*GSSAPIAuthentication.*/GSSAPIAuthentication no/" /etc/ssh/sshd_config
else
  echo "GSSAPIAuthentication no" >> /etc/ssh/sshd_config
fi

# Disable release upgrades
sed -i "s/^Prompt=.*$/Prompt=never/" /etc/update-manager/release-upgrades

# Disable APT timers and services
systemctl stop apt-daily.timer
systemctl stop apt-daily-upgrade.timer
systemctl disable apt-daily.timer
systemctl disable apt-daily-upgrade.timer
systemctl mask apt-daily.service
systemctl mask apt-daily-upgrade.service
systemctl daemon-reload

# Disable APT periodic activities
cat > /etc/apt/apt.conf.d/10periodic <<EOF
APT::Periodic::Enable "0";
APT::Periodic::Update-Package-Lists "0";
APT::Periodic::Download-Upgradeable-Packages "0";
APT::Periodic::AutocleanInterval "0";
APT::Periodic::Unattended-Upgrade "0";
EOF

# Remove the unattended upgrades package
rm -rf /var/log/unattended-upgrades
apt -y purge unattended-upgrades

# Update the repository cache
apt -y update

# Upgrade all the packages
apt -y full-upgrade -o Dpkg::Options::="--force-confnew"

# Reboot the machine
reboot
