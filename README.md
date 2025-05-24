# Vagrant Boxes

This repository contains the Packer templates to build my custom Vagrant boxes.

## Available boxes

- [joaobrlt/ubuntu-desktop-24.04](https://portal.cloud.hashicorp.com/vagrant/discover/joaobrlt/ubuntu-desktop-24.04) (amd64, libvirt)

## Requirements

- [QEMU](https://www.qemu.org/)
- [KVM](https://linux-kvm.org/)
- [libvirt](https://libvirt.org/)
- [Packer](https://www.packer.io/)

## Select

- Navigate to the desired box:

```bash
cd ubuntu-desktop-24.04
```

## Initialize

- Initialize Packer:

```bash
packer init .
```

## Lint

- Lint the code:

```bash
packer lint .
```

## Validate

- Validate the code:

```bash
packer validate .
```

## Build

- Build the box:

```bash
packer build -except=vagrant-registry .
```

## Release

- Build and release the box:

```bash
packer build -var "version=[REQUIRED]" -var "client_id=[REQUIRED]" -var "client_secret=[REQUIRED]" .
```

## License

This project is licensed under the GPLv3 License - see the [LICENSE](LICENSE) file for details.
