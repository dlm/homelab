# Recovering sops access after a key is lost

There are two kinds of key: each host's SSH-derived key (used by sops-nix),
and the cluster's age key (used by Flux). Both are recoverable from my
personal key.

## A host lost its key

This covers what to do when a host (`nuc-0`, `laptop-0`, future nodes) loses
the ability to decrypt its secrets — most commonly because it was
reinstalled, or its disk was replaced, and it booted up with a brand new SSH
host key.

This is *not* a data-loss scenario. Because my age key is a recipient on
every secrets file, this procedure just re-establishes that a specific host is
allowed to decrypt again.

### Prerequisites

* My personal age key at `~/.config/sops/age/keys.txt` on my dev machines.
* The programs `sops` and `age`

### 1. Get the new host's age public key

After a reinstall, NixOS will generate a fresh SSH host key automatically.
Convert the public key to an age key:

```bash
nix run nixpkgs#ssh-to-age -- -i /etc/ssh/ssh_host_ed25519_key.pub
```

### 2. Update `.sops.yaml`

In the repo's `.sops.yaml`, replace the value for that host's key anchor
(e.g. `&nuc-0`) with the new age public key from step 1. Keep the anchor
name the same - only the value changed.

### 3. Re-encrypt affected secrets for the new key

For every secrets file the host needs access to:

```bash
sops updatekeys systems/secrets/<file>.yaml
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

## The cluster lost its key

This covers the `sops-age` secret in the `flux-system` namespace — the age
key Flux uses to decrypt `services/secrets/*.yaml`. It is lost if the cluster
is rebuilt or the secret is deleted; Flux's `services` Kustomization will
then fail to reconcile with a decryption error.

Like the host keys, this is *not* a data-loss scenario. My age key is a
recipient on every file in `services/secrets/`, and the cluster's private key
is deliberately not kept anywhere else.

### Prerequisites

* My personal age key at `~/.config/sops/age/keys.txt`.
* The dev shell (`nix develop`), for `age`, `sops`, and `kubectl`.
* If the cluster was rebuilt: Flux bootstrapped again first, so the
  `flux-system` namespace exists.

### 1. Generate a new cluster key

In tmpfs, so the private key never touches disk:

```bash
age-keygen -o "$XDG_RUNTIME_DIR/cluster.agekey"
```

Note the `Public key: age1…` it prints.

### 2. Load it into the cluster

```bash
kubectl delete secret sops-age -n flux-system --ignore-not-found
kubectl create secret generic sops-age -n flux-system \
  --from-file=age.agekey="$XDG_RUNTIME_DIR/cluster.agekey"
rm "$XDG_RUNTIME_DIR/cluster.agekey"
```

The key name must end in `.agekey` for Flux to find it.

### 3. Update `.sops.yaml`

Replace the value of the `&cluster` anchor with the new public key.

### 4. Re-encrypt for the new key

```bash
for f in services/secrets/*.yaml; do sops updatekeys -y "$f"; done
```

### 5. Push and reconcile

```bash
git commit -am "chore: rotate cluster age key"
git push
flux reconcile kustomization flux-system --with-source
flux get kustomizations
```

`services` should be Ready again.

### If the key leaked rather than was lost

`sops updatekeys` only changes who can unlock each file; the secret values
themselves don't change, and old versions in git history can still be
decrypted with the leaked key. Follow the steps above, *then* change the
actual passwords and tokens at their source and update them with
`sops services/secrets/<file>.yaml`.
