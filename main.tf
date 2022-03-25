locals {
  nodesip = split(" ", data.external.getnodeips.result.nodes)
}

resource "exoscale_sks_cluster" "this" {
  zone    = var.zone
  name    = var.name
  service_level = var.service_level
  version = var.kubernetes_version
}

resource "exoscale_affinity" "this" {
  for_each = var.nodepools

  name = format("nodepool-%s-%s", var.name, each.key)
  type = "host anti-affinity"
}

resource "exoscale_security_group" "this" {
  name = format("nodepool-%s", var.name)
}

resource "exoscale_security_group_rule" "sks_kubelet" {
  security_group_id = exoscale_security_group.this.id
  type              = "INGRESS"
  protocol          = "TCP"
  user_security_group_id = exoscale_security_group.this.id
  start_port        = 10250
  end_port          = 10250
}

resource "exoscale_security_group_rules" "sks_admin" {
  count = length(var.sg-rules-admin)
  security_group_id = exoscale_security_group.this.id

  ingress {
    protocol  = "TCP"
    ports = [var.sg-rules-admin[count.index].port]
    cidr_list = var.sg-rules-admin[count.index].cidr
  }
}

resource "exoscale_security_group_rule" "calico_traffic" {
  security_group_id      = exoscale_security_group.this.id
  type                   = "INGRESS"
  protocol               = "UDP"
  user_security_group_id = exoscale_security_group.this.id
  start_port             = 4789
  end_port               = 4789
}

resource "exoscale_sks_nodepool" "this" {
  for_each = var.nodepools

  zone            = var.zone
  cluster_id      = exoscale_sks_cluster.this.id
  name            = each.key
  instance_type   = each.value.instance_type
  instance_prefix = lookup(each.value, "instance_prefix", "pool")
  disk_size       = lookup(each.value, "disk_size", "50")
  size            = each.value.size

  anti_affinity_group_ids = [exoscale_affinity.this[each.key].id]
  security_group_ids      = [exoscale_security_group.this.id]
  private_network_ids     = lookup(each.value, "private_network_ids", [])
}

resource "null_resource" "wait_for_cluster" {
  depends_on = [
    exoscale_sks_cluster.this,
  ]

  provisioner "local-exec" {
    command     = var.wait_for_cluster_cmd
    interpreter = var.wait_for_cluster_interpreter

    environment = {
      ENDPOINT = exoscale_sks_cluster.this.endpoint
    }
  }
}



data "external" "kubeconfig" {
  program = ["sh", "${path.module}/kubeconfig.sh"]

  query = {
    cluster_id = exoscale_sks_cluster.this.id
    zone       = var.zone
  }
}

resource "local_sensitive_file" "kube_config" {
  filename = "${path.module}/kubeconfig"
  content = data.external.kubeconfig.result.kubeconfig
}

data "external" "getnodeips" {
  
  depends_on = [local_sensitive_file.kube_config, exoscale_sks_cluster.this]
  program = ["bash", "${path.module}/nodes.sh"]

  query = {
    kubeconfig = "${path.module}/kubeconfig"
    nnodes = values(var.nodepools).0.size
  }
}
