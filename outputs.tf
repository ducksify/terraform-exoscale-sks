output "kubeconfig" {
  description = "kubectl config file contents for this SKS cluster."
  value       = data.external.kubeconfig.result.kubeconfig
  sensitive   = true
}

output "nodepools" {
  value = exoscale_sks_nodepool.this
}

output "this_security_group_id" {
  value = exoscale_security_group.this.id
}

output "nodeips" {
  value = jsondecode(data.external.getnodeips.result.nodes).items[*].status.addresses[0].address
}

