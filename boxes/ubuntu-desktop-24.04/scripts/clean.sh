#!/bin/bash
set -eux

export DEBIAN_FRONTEND=noninteractive

# Remove the orphan packages
apt autoremove -y --purge

# Clean the apt archives
apt clean

# Clean the apt lists
rm -rf /var/lib/apt/lists/*
