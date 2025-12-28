# Homelab IaC

Hypervisor: Proxmox VE
Kubernetes: K3S
Number of clusters: 2

## CLI tools to install

Brew: kubectl, opentofu, ansible, FluxCD CLI, kustomize, age, sops

## Rendered Manifests Pattern

Usage:

./renderer.sh --chart traefik --repo https://traefik.github.io/charts --version 38.0.1 --release traefik --namespace traefik --is-infrastructure false

Test fully customized manifest before deployment:

kustomize build <path_to_kustomization.yaml>

Check flux logs during/after deployment:

- flux get kustomizations -A
- flux logs

In case of failures, get more information from Kubernetes directly:

kubectl -n traefik-ext describe deployment traefik

### Force recreate deleted resources

flux reconcile kustomization apps --with-source

### Edit resource in-place for debugging

kubectl edit ingressroute/traefik-dashboard -o yaml -n traefik-ext 

Delete related pods if configuration is not reloaded automatically. They will be restarted.

### Reconciliation log

kubectl -n flux-system logs deploy/kustomize-controller

### Delete whole application resources by namespace

kubectl delete namespace authentik

## Traefik

### Gateway API

Check that GatewayClass (a cluster-wide resource) points to Traefik: kubectl get gatewayclass
kubectl get gateway -n traefik-ext
kubectl get httproute -n traefik-ext

Traefik service logs: kubectl logs svc/traefik -n traefik-ext

## Shared resources

Some resources like Kubernetes Secrets are not accessible from another namespace, and using the "default" namespace is a bad practice. 
But many applications require initContainers with git-sync to populate them with static data like configuration, webpages, etc. from the private repo.
To avoid duplication of same resources for each namespace where they're needed, there is a flux/shared-resources/ directory. 
Each shared resource has its separate directory and can be included in Kustomization.yaml of any app/infrastructure where it is needed.
A copy will be created in the clusterfor each namespace on the reconciliation step.

## TODOs

- Connect renovate or dependabot to Github repo for getting update PRs
