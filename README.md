# Linux Admin Toolkit


A modular Bash framework for Linux system administration,

diagnostics, monitoring, auditing and backups.


## Requirements


- Bash 5+

- Linux

- Coreutils

- iproute2

- procps

- tar

- sha256sum


## Installation


```bash

git clone https://github.com/TON_USERNAME/linux-admin-toolkit.git

cd linux-admin-toolkit


chmod +x bin/lat tests/test_core.sh


sudo ln -sfn "$PWD/bin/lat" /usr/local/bin/lat
