# machina

## Goal

The installed `snaps` on Fedora Silverblue are failing to start because it doesn't support OS's where the user's home directory are not in the `/home` standard path.

One of the softwares that I really like and is only available as a `snap`, is [multipass](https://github.com/canonical/multipass), an orchestrator for Ubuntu virtual machines.

The main goal of this tool is to allow me to quickly create kvm virtual machines with the least amount of effort, as an alternative to multipass where it's not available.

## Installation

To install the `machina` script, just clone the repo and copy the `machina` script file into a directory on the path, such us `/usr/local/bin` or `$HOME/.local/bin`

Install the dependencies

```shell
sudo rpm-ostree install cloud-utils libvirt qemu-kvm virt-manager virt-install virt-viewer #libvirt-daemon-config-network libvirt-daemon-kvm
```

Add the user to the libvirt group
```shell
grep -E '^libvirt:' /usr/lib/group | sudo tee -a /etc/group
usermod -aG libvirt $USERNAME
```

Activate the `default` network interface
```shell
virsh --connect=qemu:///system net-autostart default
````

## Permissions

Add user to `libvirt` group

```bash
grep -E '^libvirt:' /usr/lib/group | sudo tee -a /etc/group
usermod -aG libvirt username
```

Add your user and group to `/etc/libvirt/qemu.conf`

```toml
user = "me"
group = "wheel"
```

## Usage

### Create a `machina`


