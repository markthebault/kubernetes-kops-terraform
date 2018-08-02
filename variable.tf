variable "tags" {
  type = "map"

  default {
    Account           = "test"
    Environment       = "dev"
    Terraform         = "true"
    KubernetesCluster = "awesome-k8s-cluster"
  }
}

variable "main_domain" {
  default = "k8s.com"
}

variable "cluster_name" {
  default = "awesome-k8s-cluster"
}

variable "key_name" {
  default = "master_key"
}

variable "private_subnets" {
  default = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
}

#public subnets
# To be changed
variable "public_subnets" {
  default = ["10.1.101.0/24", "10.1.102.0/24", "10.1.103.0/24"]
}

variable "kubernetes_public_subnets_cidr" {
  default = ["10.1.11.0/24", "10.1.12.0/24", "10.1.13.0/24"]
}

variable "AZS" {
  default = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}

variable "region" {
  default = "eu-west-1"
}

variable "env" {
  default = "dev"
}


variable "kubernetes_version" {
  default = "1.9.8"
}