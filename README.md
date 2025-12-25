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

Check flux logs during/after deployment:

- flux get kustomizations -A
- flux logs

In case of failures, get more information from Kubernetes directly:

kubectl -n traefik-ext describe deployment traefik

## Traefik

### Gateway API

Check that GatewayClass (a cluster-wide resource) points to Traefik: kubectl get gatewayclass
kubectl get gateway -n traefik-ext
kubectl get httproute -n traefik-ext

Traefik service logs: kubectl logs svc/traefik -n traefik-ext

## TODOs

- Connect renovate or dependabot to Github repo for getting update PRs
