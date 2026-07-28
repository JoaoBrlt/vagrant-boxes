#!/bin/bash
set -eux

export DEBIAN_FRONTEND=noninteractive

# Remove the orphan packages
apt-get autoremove -y --purge

# Clean the apt archives
apt-get clean

# Clean the apt lists
rm -rf /var/lib/apt/lists/*
