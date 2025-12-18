#!/bin/sh

# export variables from .env
set -a
set -o allexport
source .env

# Substitute environment with actual values
SCRIPT_WITH_VALUES=$(envsubst < ./create-debian-template.sh)

ssh -o StrictHostKeyChecking=no -l root pve "eval $SCRIPT_WITH_VALUES"
