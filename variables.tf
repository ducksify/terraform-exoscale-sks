variable "name" {
  description = "The name of the SKS cluster."
  type        = string
}

variable "zone" {
  description = "The name of the zone to deploy the SKS cluster into."
  type        = string
}

variable "kubernetes_version" {
  description = "The kubernetes version to use. See the Exoscale documentation or portal for possible choices."
  type        = string
}

variable "service_level" {
  description = "The SKS kubernetes service_level version to use. See the Exoscale documentation or portal for possible choices."
  type        = string
}


variable "nodepools" {
  description = "The SKS node pools to create."
  type        = map(any)
}

variable "wait_for_cluster_cmd" {
  description = "Custom local-exec command to execute for determining if the eks cluster is healthy. Cluster endpoint will be available as an environment variable called ENDPOINT"
  type        = string
  default     = "for i in `seq 1 60`; do if `command -v wget > /dev/null`; then wget --no-check-certificate -O - -q $ENDPOINT/healthz >/dev/null && exit 0 || true; else curl -k -s $ENDPOINT/healthz >/dev/null && exit 0 || true;fi; sleep 5; done; echo TIMEOUT && exit 1"
}

variable "wait_for_cluster_interpreter" {
  description = "Custom local-exec command line interpreter for the command to determining if the eks cluster is healthy."
  type        = list(string)
  default     = ["/bin/sh", "-c"]
}

variable "node_ports_world_accessible" {
  description = "Create a security group rule that allows world access to to NodePort services."
  type        = bool
  default     = true
}
# Security group for accessing admin in cluster
variable "sg-rules-admin" {
  type = list(object({
    port = string
    cidr = list(string)
  }))
  default = [
    {
      "port" = "31443"
      "cidr" = ["1.1.1.1/32", "2.2.2.2/32"]
    },
    {
      "port" = "31080"
      "cidr" = ["1.1.1.1/32", "2.2.2.2/32"]
    },

  ]
}
