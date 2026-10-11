# Recovering sops-nix access after a host loses its key

This covers what to do when a host (`nuc-0`, `laptop-0`, future nodes) loses
the ability to decrypt its secrets — most commonly because it was
reinstalled, or its disk was replaced, and it booted up with a brand new SSH
host key.

This is *not* a data-loss scenario. Because my age key is a recipient on
every secrets file, this procedure just re-establishes that a specific host is
allowed to decrypt again.

## Prerequisites

* My personal age key at `~/.config/sops/age/keys.txt` on my dev machines.
* The programs `sops` and `age`

## Steps

### 1. Get the new host's age public key

After a reinstall, NixOS will generate a fresh SSH host key automatically.
Convert the public key to an age key:

```bash
nix run nixpkgs#ssh-to-age -- -i /etc/ssh/ssh_host_ed25519_key.pub
```

### 2. Update `.sops.yaml`

In the repo's `.sops.yaml`, replace the value for that host's key anchor
(e.g. `&nuc_0`) with the new age public key from step 1. Keep the anchor
name the same - only the value changed.

### 3. Re-encrypt affected secrets for the new key

For every secrets file the host needs access to:

```bash
sops updatekeys secrets/<file>.yaml
```

This decrypts using my key and re-encrypts for the current recipient
list in `.sops.yaml` — including the host's new key. The host's old key is
not needed for this step at all.

### 4. Redeploy

```bash
just deploy <host>
```

Once the new config lands, the host can decrypt its secrets again using its
new SSH-derived identity.
