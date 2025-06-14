# Vagrant Boxes

[![CI][ci-badge-url]][ci-workflow-url]
[![CD][cd-badge-url]][cd-workflow-url]

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
cd boxes/...
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

## Deploy

- Build and deploy the box:

```bash
packer build -var "version=[REQUIRED]" -var "client_id=[REQUIRED]" -var "client_secret=[REQUIRED]" .
```

## License

This project is licensed under the GPLv3 License - see the [LICENSE](LICENSE) file for details.

[ci-badge-url]: https://github.com/JoaoBrlt/vagrant-boxes/actions/workflows/ci.yml/badge.svg
[ci-workflow-url]: https://github.com/JoaoBrlt/vagrant-boxes/actions/workflows/ci.yml
[cd-badge-url]: https://github.com/JoaoBrlt/vagrant-boxes/actions/workflows/cd.yml/badge.svg
[cd-workflow-url]: https://github.com/JoaoBrlt/vagrant-boxes/actions/workflows/cd.yml