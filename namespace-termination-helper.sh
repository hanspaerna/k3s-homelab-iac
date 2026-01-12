#!/bin/sh

for api in $(kubectl api-resources --verbs=list --namespaced -o name); do
 echo "Checking $api in namespace 'jellyfin'..."
 kubectl get -n jellyfin $api --ignore-not-found
done
