# services

Kubernetes workloads that run on top of k3s (see `../systems/`).

[Flux](https://fluxcd.io/) applies everything in this directory via the
`services` Kustomization in `../clusters/homelab/services.yaml`. Push to
`main` to deploy; don't `kubectl apply` these by hand.

Secrets go in `secrets/<app>.yaml`, sops-encrypted for me and the cluster
(see `../.sops.yaml`). Edit them with `sops`, never by hand -- the MAC
covers the plaintext fields too.
