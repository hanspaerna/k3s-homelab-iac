# Homelab IaC

Hypervisor: Proxmox VE
Kubernetes: K3S
Number of clusters: 2

## CLI tools to install

Brew: kubectl, opentofu, ansible, FluxCD CLI, kustomize, age, sops

## Rendered Manifests Pattern

Usage:

./render-chart.sh --chart traefik --repo https://traefik.github.io/charts --version 38.0.1 --release traefik --namespace traefik --is-infrastructure false

Test fully customized manifest before deployment:

kustomize build <path_to_kustomization.yaml>


## TODOs

- Connect renovate or dependabot to Github repo for getting update PRs
