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
sed -i -e "s/^Prompt=.*$/Prompt=never/" /etc/update-manager/release-upgrades

# Disable APT periodic activities
echo 'APT::Periodic::Enable "0";' > /etc/apt/apt.conf.d/10periodic

# Update the repository cache
apt -y update

# Upgrade all the packages
apt -y full-upgrade -o Dpkg::Options::="--force-confnew"

# Reboot the machine
reboot
