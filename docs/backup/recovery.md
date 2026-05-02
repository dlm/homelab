# Using restic

This document outlines how to recover data using restic with a repository that
resides on nuc-0.

Should we need to perform a recovery:
* Do NOT improvise
* Follow steps exactly
* Prefer restoring to a new location first
* Verify before replacing any data

Note that the commands are bash commands (not nushell), so if future dave is
still using nushll, you will need to start a bash shell on petrillo.

## Prerequisites

We will require access to `nuc-0` the restic repo is at
`sftp:dave@nuc-0:/backups/restic/petrillo` and will require secrets at
`~/.config/sops-nix/secrets/hosts/petrillo/{restic-password,restic-ssh-key}`

## Recovering from Data Loss on petrillo

### Health check

First check the snapshots:

```bash
restic \
  -r sftp:dave@nuc-0:/backups/restic/petrillo \
  --password-file ~/.config/sops-nix/secrets/hosts/petrillo/restic-password \
  snapshots
```

You should see at least one snapshot and hopefully a recent timestamp.

### List available data

Next, list out what we have available (and pray that the thing you wanted was
actually backed up).

```bash
restic \
  -r sftp:dave@nuc-0:/backups/restic/petrillo \
  --password-file ~/.config/sops-nix/secrets/hosts/petrillo/restic-password \
  ls latest | head -50
```

### Restore data

To restore the entire repo:

```bash
mkdir ~/tmp/recover
restic \
  -r sftp:dave@nuc-0:/backups/restic/petrillo \
  --password-file ~/.config/sops-nix/secrets/hosts/petrillo/restic-password \
  restore latest \
  --target ~/tmp/recover
```

Or, just a specific folder, for example the `repos`:
```bash
restic \
  -r sftp:dave@nuc-0:/backups/restic/petrillo \
  --password-file ~/.config/sops-nix/secrets/hosts/petrillo/restic-password \
  restore latest \
  --include /home/dave/repos \
  --target ~/recover
```

## Recovering from disk failure in nuc-0

First breath, we set up zfs with mirroring so that we can handle failure.
On `nuc-0`, first check that status:

```bash
zpool status backup
```

Next replace the disk with:
```bash
zpool replace backup <old-disk> <new-disk>
```

And recheck the status with:
```bash
zpool status
```

## Other maintenance

It is good to periodically validate the backup integrity with:

```bash
restic \
  -r sftp:dave@nuc-0:/backups/restic/petrillo \
  --password-file ~/.config/sops-nix/secrets/hosts/petrillo/restic-password \
  check
```





