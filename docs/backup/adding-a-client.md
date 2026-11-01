# Adding a backup client

This document outlines how to start backing up another machine to the restic
repository on nuc-0. The setup is spread across three repos, and nothing
checks that they agree, so a missed step only shows up as a failed backup.

Commands are bash (not nushell). `<host>` is the new machine's hostname, as
set by `networking.hostName`.

## Where the pieces live

| Repo | File | What |
|---|---|---|
| key-safe | `always.enc.yaml` | `hosts.<host>.restic-password` and `hosts.<host>.restic-ssh-key` |
| homelab | `systems/modules/users.nix` | the `restic@<host>` public key, authorized for `dave` |
| homelab | `systems/hosts/nuc-0/configuration.nix` | the `/backups/restic/<host>` directory |
| nixos | `hosts/<host>/configuration.nix` | `stacks.backup` with the names of those two secrets and what to back up |

The same list applies when renaming a host, removing one, or rotating its
restic key.

## Prerequisites

* The host is already set up from the nixos repo.
* My personal age key at `~/.config/sops/age/keys.txt` on the host.

## Steps

Do these in order: nuc-0 has to accept the new key before the host's first
backup runs.

### 1. Generate the restic key and password

Work in the runtime directory so the private key never touches disk:

```bash
cd "$XDG_RUNTIME_DIR"
ssh-keygen -t ed25519 -N "" -C "restic@<host>" -f restic-<host>
head -c 32 /dev/urandom | base64 > restic-<host>-password
```

The password encrypts the restic repository. Losing it means losing the
backups, and it only lives in key-safe.

### 2. Add the secrets to key-safe

```bash
cd ~/repos/dlm/key-safe
sops always.enc.yaml
```

Add an entry under `hosts`, alongside the existing hosts:

```yaml
hosts:
    <host>:
        restic-password: <contents of restic-<host>-password>
        restic-ssh-key: |
            -----BEGIN OPENSSH PRIVATE KEY-----
            ...
            -----END OPENSSH PRIVATE KEY-----
```

Commit and push.

### 3. Prepare nuc-0

In homelab:

* `systems/modules/users.nix`: add the contents of `restic-<host>.pub` under
  "keys for restic backup tasks".
* `systems/hosts/nuc-0/configuration.nix`: add a directory alongside the
  existing ones:

  ```nix
  "d /backups/restic/<host> 0755 dave users -"
  ```

Deploy, then commit:

```bash
just deploy nuc-0
```

### 4. Enable backups on the host

In the nixos repo, pull in the new secrets:

```bash
nix flake update key-safe
```

Then add to `hosts/<host>/configuration.nix`:

```nix
stacks.backup = {
  enable = true;
  passwordSecret = "hosts/<host>/restic-password";
  sshKeySecret = "hosts/<host>/restic-ssh-key";
  paths = [
    "/home/dave/repos"
    # ...
  ];
};
```

Rebuild the host and commit.

### 5. Verify

Check the secrets were decrypted:

```bash
ls ~/.config/sops-nix/secrets/hosts/<host>/
```

Run a backup now instead of waiting for the timer. The repository is created
on the first run.

```bash
sudo systemctl start restic-backups-main
journalctl -u restic-backups-main -e
```

Then confirm a snapshot exists, as in the health check in
[recovery.md](recovery.md):

```bash
restic \
  -r sftp:dave@nuc-0:/backups/restic/<host> \
  --password-file ~/.config/sops-nix/secrets/hosts/<host>/restic-password \
  snapshots
```

### 6. Clean up

```bash
rm "$XDG_RUNTIME_DIR"/restic-<host> "$XDG_RUNTIME_DIR"/restic-<host>.pub "$XDG_RUNTIME_DIR"/restic-<host>-password
```
