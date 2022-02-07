# terraform-exoscale-sks

A terraform module to create a managed Kubernetes cluster on Exoscale SKS.

This module creates an SKS cluster with one or more node pools. It creates one security group for all instances with the minimum rules recommended in the exoscale documentation. It also creates one anti-affinity group for each node pool. It then automatically retrieves the kubeconfig that allows access to the cluster.


## Usage example

```hcl
module "sks" {
  source  = "registry.terraform.io/ducksify/sks/exoscale"
  version = "0.3.2"

  name = "test"
  zone = "ch-gva-2"

  kubernetes_version = "1.22.5"

  nodepools = {
    "router" = {
      instance_type = "standard.small"
      size          = 1
    },
    "compute" = {
      instance_type = "standard.small"
      size          = 3
    }
  }
}
```
