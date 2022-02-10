#!/bin/bash
set -e

eval "$(jq -r '@sh "KUBECONFIG=\(.kubeconfig)"')"


nodes=$(kubectl get node --kubeconfig $KUBECONFIG  -o json)

jq -M -r -s  -n --arg nodes "$nodes" '{"nodes":$nodes}'