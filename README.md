# Homelab IaC

Hypervisor: Proxmox VE
Kubernetes: K3S
Number of clusters: 2

## CLI tools to install

Brew: kubectl, opentofu, ansible, FluxCD CLI, kustomize, age, sops

## Rendered Manifests Pattern

Usage:

./renderer.sh --chart kubernetes-operator --repo-name netbirdio --repo https://netbirdio.github.io/kubernetes-operator --version 0.1.15 --folder netbird-operator --namespace netbird-operator --is-infrastructure false

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

If it's stuck in "Terminating", more radical measures needed:

kubectl get namespace <NAMESPACE> -o json \
| jq '.spec.finalizers=[]' \
| kubectl replace --raw "/api/v1/namespaces/<NAMESPACE>/finalize" -f -

### Test connectivity between pods/services

kubectl run -i --rm curl-test \
  --image=curlimages/curl:8.2.1 \
  --restart=Never \
  --namespace=traefik \
  -- sh -c "nslookup authelia.authelia.svc.cluster.local && curl -v http://authelia.authelia.svc.cluster.local:80/api/verify"

### Suspend Flux during debugging with kubectl apply

You may run flux suspend kustomizations --all to avert Flux from reconciling during an incident or other times.

### Add Crowdsec bouncer with your pre-defined key

cscli bouncers add test-bouncer -k <your_key> 

## Traefik

### Gateway API

Check that GatewayClass (a cluster-wide resource) points to Traefik: kubectl get gatewayclass
kubectl get gateway -n traefik-ext
kubectl get httproute -n traefik-ext

Traefik service logs: kubectl logs svc/traefik -n traefik-ext

NB! Each namespace requires a Middleware chain to use Authelia auth middleware, this is the only cross-namespace workaround right now that allows to prevent duplication.

## Shared resources

Some resources like Kubernetes Secrets are not accessible from another namespace, and using the "default" namespace is a bad practice. 
But many applications require initContainers with git-sync to populate them with static data like configuration, webpages, etc. from the private repo.
To avoid duplication of same resources for each namespace where they're needed, there is a flux/shared-resources/ directory. 
Each shared resource has its separate directory and can be included in Kustomization.yaml of any app/infrastructure where it is needed.
A copy will be created in the clusterfor each namespace on the reconciliation step.

## TODOs

- Connect renovate or dependabot to Github repo for getting update PRs

## Authelia

A secret code to create TOTP will be created in the authelia's container: /config/notification.txt
