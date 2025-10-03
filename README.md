# debian-frr-lab
Vagrant-based Debian 13 EVPN spine–leaf lab with FRR. No Guest Additions, ready-to-SSH via .ssh/config. Includes Ansible plays for various levels of network designs.


# Debian Trixie EVPN Spine–Leaf Lab (VirtualBox + Vagrant + Ansible-ready)

This project provides a ready-to-use Vagrant environment for experimenting with EVPN / BGP / Spine–Leaf topologies on Debian 13 (Trixie).  
It avoids Guest Additions and synced folders for maximum portability, and comes with a clean setup:

- Each VM already has a `nico` user with passwordless `sudo`.
- SSH access is available immediately after `vagrant up`.
- FRR is preinstalled and enabled on all nodes.

## Topology

- **Spines:** 2 nodes  
- **Leaves:** 3 nodes  
- **Test VMs:** 3 end hosts  
- Internal links are plain VirtualBox intnet networks mimicking direct physical links (no auto IP).

## Requirements

- VirtualBox
- Vagrant

## Usage

Bring up the full lab:

```bash
git clone https://github.com/YOURNAME/debian-frr-lab.git
cd debian-frr-lab
vagrant up
````

## SSH Access

Vagrant sets up port forwards for each node (e.g. `leaf01` on port 2211).
Instead of remembering ports, you can populate your `~/.ssh/config` with (replace nico with your own username of course):

```bash
cd ~/debian-frr-lab
vagrant ssh-config >> ~/.ssh/config
echo 'Host leaf01 leaf02 leaf03 spine01 spine02 vm01 vm02 vm03
  User nico' >> ~/.ssh/config
```

Now you can simply:

```bash
ssh leaf01
ssh leaf02
ssh leaf03
ssh spine01
ssh spine02
ssh vm01
ssh vm02
ssh vm03
```

…and you’ll be logged in as `nico` (or your own user) with passwordless sudo.

## Why no Guest Additions?

We deliberately disable Guest Additions / synced folders:

* Keeps the boxes small and clean.
* No dependency on the `vagrant-vbguest` plugin.
* All provisioning is done via inline shell (user creation, sudo setup, FRR install).

This ensures the lab is reproducible across systems with minimal requirements.

## Cleanup

To destroy the environment completely:

```bash
vagrant destroy -f
```

---

Enjoy hacking on FRR with a minimal, repeatable Debian Trixie lab!

```
