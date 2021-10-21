# machina

## Goal

The installed `snaps` on Fedora Silverblue are failing to start because it doesn't support OS's where the user's home directory are not in the `/home` standard path.

One of the softwares that I really like and is only available as a `snap` is [multipass](https://github.com/canonical/multipass), an orchestrator for Ubuntu virtual machines.

The main goal of this tool is to allow to quickly create kvm virtual machines with the least amount of effort, as an alternative to multipass where it's not available.

## Installation

To install the `machina` script, just clone the repo and copy the `machina` script file into a directory on the path, such us `/usr/local/bin` or `$HOME/.local/bin` or just run the following command:

```bash
curl -s https://raw.githubusercontent.com/enkodr/machina.sh/main/machina.sh -o $HOME/.local/bin/machina.sh
```

## Dependencies 

Install the following dependencies

```shell
sudo rpm-ostree install cloud-utils libvirt qemu-kvm virt-manager virt-install virt-viewer #libvirt-daemon-config-network libvirt-daemon-kvm
```

## Permissions

The following permissions are needed if you want to create a machine in the `system` hypervisor.

### Add user to `libvirt` group

```bash
grep -E '^libvirt:' /usr/lib/group | sudo tee -a /etc/group
usermod -aG libvirt username
```

### Add your user and group to `/etc/libvirt/qemu.conf`

```toml
user = "me"
group = "wheel"
```

## Usage

### Create a `machina`

The following command will create a `machina` with the default settings. You can check the default settings by running `machina help create`

```bash
machina create
```

Example with specified settings:

```bash
machina create --name debian --image debian11 --disk 40 --mem 4 --cpus 2
```

### Shell into a `machina`

```bash
machina shell ubuntu
```

### Stop a running `machina`

```bash
machina stop ubuntu
```

### Start a stopped `machina`

```bash
machina start ubuntu
```

### Reboot a running `machina`

```bash
machina reboot ubuntu
```

### Get the help for a command

```bash
machina help <command_name>
```

Example:
```bash
machina help create
```

## TODO

The following items are in my todo list:

- [ ] Update the cloud image(s)
- [ ] Reset everything
- [ ] Mount directories into the machines