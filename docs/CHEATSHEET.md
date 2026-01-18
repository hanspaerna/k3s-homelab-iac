### Rescue pods

When Postgres needs to be inspected/modified:

```
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: pvc-inspector
  namespace: <ns>
spec:
  containers:
  - name: pvc-inspector
    image: postgres:<pg_version>
    env:
    - name: POSTGRES_USER
      value: <username>
    - name: POSTGRES_PASSWORD
      value: <password>
    - name: POSTGRES_DB
      value: <dbname>
    volumeMounts:
    - mountPath: /var/lib/postgresql/data
      name: data
  volumes:
  - name: data
    persistentVolumeClaim:
      claimName: <pvc_to_repair>
EOF
```

For general use:

```
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: pvc-inspector-busybox
  namespace: <ns>
spec:
  containers:
  - name: pvc-inspector
    image: busybox
    command: [ "/bin/sh", "-c", "--" ]
    args: [ "while true; do sleep 30; done;" ]
    volumeMounts:
    - mountPath: /var/data
      name: data
  volumes:
  - name: data
    persistentVolumeClaim:
      claimName: <pvc_to_repair>
EOF
```

Use 'kubectl cp' to transfer files.

### Force recreate deleted resources

flux reconcile kustomization apps --with-source

### Validate kustomization

kustomize build ./flux/apps/int/navidrome

### Edit resource in-place for debugging

kubectl edit ingressroute/traefik-dashboard -o yaml -n traefik-ext 

### Reconciliation log

kubectl -n flux-system logs deploy/kustomize-controller

### Test connectivity between pods/services

kubectl run -i --rm curl-test \
  --image=curlimages/curl:8.2.1 \
  --restart=Never \
  --namespace=traefik \
  -- sh -c "nslookup authelia.authelia.svc.cluster.local && curl -v http://authelia.authelia.svc.cluster.local:80/api/verify"

### Suspend Flux during debugging with kubectl apply

You may run flux suspend kustomizations --all to avert Flux from reconciling during an incident or other times.

### Add Crowdsec bouncer with your pre-defined key

cscli bouncers add traefik-bouncer -k <your_key> 
