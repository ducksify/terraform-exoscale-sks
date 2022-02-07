#!/bin/bash
set -e

nodes=$(kubectl get node --kubeconfig  ${path.module}/kubeconfig  -o json)

jq -M -r -s  -n --arg nodes "$nodes" '{"nodes":$nodes}'