#!/bin/bash
set -e

eval "$(jq -r '@sh "KUBECONFIG=\(.kubeconfig) NNODES=\(.nnodes)"')"

check_deploy() {
for i in  seq {1..30}
do
  if   [ $(KUBECONFIG=$KUBECONFIG kubectl get nodes |grep -c Ready) == $NNODES ]
  then
    exit 0
  fi
  echo sleep
  sleep 5
done
}

result=$(check_deploy)

nodes=$(kubectl get node --kubeconfig $KUBECONFIG  -o jsonpath="{.items[*].status.addresses[?(@.type=='ExternalIP')].address}")

jq -M -r -s  -n --arg nodes "$nodes" '{"nodes":$nodes}'