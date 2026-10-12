# homelab

This repo is a playground for my homelab.

## Layout

- `systems/` — NixOS configuration for each physical/virtual host (`hosts/`,
  `modules/`, secrets, and the flake that defines `nixosConfigurations`).
  This is what provisions a machine and gets it running k3s.
- `services/` — what runs on top of k3s, managed via Flux (GitOps) rather
  than Nix.
- Root `flake.nix` — just the dev shell for working in this repo (`just`,
  `git`, etc.); unrelated to the systems themselves.

## Adding a new node

This is roughly the set of steps.  There may be errors since I have only run
this a few times. It would be worth adding as a script if I started adding more
notes.

```bash
nix-shell -p git gh vim
my_hostname=<whatever-you-want>
ssh-keygen -t ed25519 -C "$(my_hostname)" -f ~/.ssh/id_ed25519 -N ""
gh ssh-key add ~/.ssh/id_ed25519.pub --title "$(my_hostname)"
git clone git@github.com:dlm/homelab.git
```

Setup the nix config for the new host:

```bash
cd homelab
mkdir "systems/hosts/$(my_hostname)"
cp /etc/nixos/hardware-configuration.nix "./systems/hosts/$(my_hostname)"
cp ./systems/hosts/nuc-0/configuration.nix ./systems/hosts/$(my_hostname)/"
```

Then update `./systems/hosts/$(my_hostname)/configuration.nix` as is appropriate for
the device you are adding.  You will most likely want to (at least):

1. get the `# Bootloader` values from `/etc/nixos/configuration.nix`
2. get the `system.stateVersion` from `/etc/nixos/configuration.nix`
2. set `networking.hostName`

Initialize tailscale

```bash
sudo tailscale up
```


## TODO
- setup firewall
