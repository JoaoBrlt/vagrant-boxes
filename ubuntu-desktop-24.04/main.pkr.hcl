packer {
  required_version = ">= 1.11.0"

  required_plugins {
    qemu = {
      version = "~> 1"
      source  = "github.com/hashicorp/qemu"
    }
    vagrant = {
      version = "~> 1"
      source  = "github.com/hashicorp/vagrant"
    }
  }
}

variable "client_id" {
  type        = string
  description = "The service principal client ID for the HCP API. Required when releasing a new version."
  default     = "NO_VALUE"
  sensitive   = true
}

variable "client_secret" {
  type        = string
  description = "The service principal client secret for the HCP API. Required when releasing a new version."
  default     = "NO_VALUE"
  sensitive   = true
}

variable "version" {
  type        = string
  default     = "NO_VALUE"
  description = "The version number. Required when releasing a new version."
}

source "qemu" "vm" {
  # Builder configuration
  accelerator      = "kvm"
  headless         = true
  output_directory = "builds/ubuntu-desktop-24.04-amd64-qemu"

  # General configuration
  vm_name = "ubuntu-desktop-24.04-amd64"
  cpus    = 2
  memory  = 4096

  # Disk configuration
  disk_interface = "virtio"
  disk_size      = 65536
  format         = "qcow2"

  # Network configuration
  net_device = "virtio-net"

  # ISO configuration
  iso_url      = "https://old-releases.ubuntu.com/releases/noble/ubuntu-24.04.1-desktop-amd64.iso"
  iso_checksum = "sha256:c2e6f4dc37ac944e2ed507f87c6188dd4d3179bf4a3f9e110d3c88d1f3294bdc"

  # HTTP server configuration
  http_directory = "http"

  # Shutdown configuration
  shutdown_command = "echo 'vagrant' | sudo -S shutdown -P now"

  # SSH configuration
  ssh_username = "vagrant"
  ssh_password = "vagrant"
  ssh_port     = 22
  ssh_timeout  = "30m"

  # Boot configuration
  boot_wait = "10s"
  boot_command = [
    "c<wait>",
    "linux /casper/vmlinuz --- autoinstall ds=\"nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/\"<enter><wait>",
    "initrd /casper/initrd<enter><wait>",
    "boot<enter><wait>"
  ]
}

build {
  sources = ["source.qemu.vm"]

  # Configure the machine for Vagrant
  provisioner "shell" {
    execute_command   = "echo 'vagrant' | {{.Vars}} sudo -S -E bash '{{.Path}}'"
    script            = "scripts/setup.sh"
    expect_disconnect = true
    pause_after       = "30s" # Wait for the machine to reboot
  }

  post-processors {
    # Convert the artifact into a Vagrant box
    post-processor "vagrant" {
      compression_level = 9
      output            = "builds/ubuntu-desktop-24.04-amd64-{{.Provider}}.box"
    }

    # Deploy the Vagrant box to the HCP Vagrant Box Registry
    post-processor "vagrant-registry" {
      client_id     = "${var.client_id}"
      client_secret = "${var.client_secret}"
      box_tag       = "joaobrlt/ubuntu-desktop-24.04"
      version       = "${var.version}"
      architecture  = "amd64"
    }
  }
}
