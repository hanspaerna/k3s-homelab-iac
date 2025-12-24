# Homelab IaC


## CLI tools to install

Brew: kubectl, opentofu, ansible, FluxCD CLI, age, sops

## Rendered Manifests Pattern

Usage:

./render-chart.sh --chart traefik --repo https://traefik.github.io/charts --version 38.0.1 --release traefik --namespace traefik --is-infrastructure false
