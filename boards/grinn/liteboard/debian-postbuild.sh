#!/bin/bash

set -e -x

sudo ${DEBIAN_ENVS} chroot ${ROOTFS_DIR} sh -c 'echo "liteboard" > /etc/hostname'
sudo ${DEBIAN_ENVS} chroot ${ROOTFS_DIR} sh -c 'echo "127.0.0.1 liteboard" >> /etc/hosts'
sudo ${DEBIAN_ENVS} chroot ${ROOTFS_DIR} sh -c 'echo "\nauto eth0\nallow-hotplug eth0\niface eth0 inet dhcp" >> /etc/network/interfaces'
sudo ${DEBIAN_ENVS} chroot ${ROOTFS_DIR} sh -c 'echo root:root | chpasswd'
