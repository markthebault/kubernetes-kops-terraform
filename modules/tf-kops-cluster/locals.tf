locals {
  # Currently support kops version
  supported_kops_version = "1.9.2"

  # Removes the last character of the FQDN if it is '.'
  cluster_fqdn = "${replace(var.cluster_fqdn, "/\\.$/", "")}"

  # AZ names and letters are used in tags and resources names
  az_names       = "${sort(data.aws_availability_zones.available.names)}"
  az_letters_csv = "${replace(join(",", local.az_names), data.aws_region.current.name, "")}"
  az_letters     = "${split(",", local.az_letters_csv)}"

  # Number master resources to create. Defaults to the number of AZs in the region but should be 1 for regions with odd number of AZs.
  master_resource_count = "${var.force_single_master == 1 ? 1 : length(local.az_names)}"

  # Master AZs is used in the `kops create cluster` command
  master_azs = "${var.force_single_master == 1 ? element(local.az_names, 0) : join(",", local.az_names)}"

  # etcd AZs is used in tags for the master EBS volumes
  etcd_azs = "${var.force_single_master == 1 ? element(local.az_letters, 0) : local.az_letters_csv}"

  # Subnet IDs to be used by k8s ASGs
  k8s_subnet_ids = "${length(var.private_subnet_ids) == 0 ? join(",", aws_subnet.public.*.id) : join(",", var.private_subnet_ids)}"
}

locals {
  k8s_versions = {
    "1.9.8" = {
      kubelet_hash   = "6468397888494efe4a32e6bd96700ba6a86e635a"
      kubectl_hash   = "9a3537a7d95f1beec55e2fae082c364f6b91fdc0"
      cni_hash       = "d595d3ded6499a64e8dac02466e2f5f2ce257c9f"
      cni_file_name  = "cni-plugins-amd64-v0.6.0.tgz"
      utils_hash     = "72fac6679084d1f929d0abbd8a9ff9337273504b"
      protokube_hash = "527db0b5fd4b635e6cb2ca22bfec813a048855a7"
      ami_name       = "k8s-1.9-debian-jessie-amd64-hvm-ebs-2018-03-11"
      docker_version = "17.03.2"
    }

    "1.8.7" = {
      kubelet_hash   = "0f3a59e4c0aae8c2b2a0924d8ace010ebf39f48e"
      kubectl_hash   = "36340bb4bb158357fe36ffd545d8295774f55ed9"
      cni_hash       = "1d9788b0f5420e1a219aad2cb8681823fc515e7c"
      cni_file_name  = "cni-0799f5732f2a11b329d9e3d51b9c8f2e3759f2ff.tar.gz"
      utils_hash     = "aad29883ed2ad2288f708487e1217c079604e9ef"
      protokube_hash = "439b34ab45d5dbe309c7235890ec753e1f6bd9a1"
      ami_name       = "k8s-1.8-debian-jessie-amd64-hvm-ebs-2018-03-11"
      docker_version = "1.13.1"
    }

    "1.8.6" = {
      kubelet_hash   = "96c23396f0bb67fae0da843cc5765d0e8411e552"
      kubectl_hash   = "59f138a5144224cb0c8ed440d3a0a0e91ef01271"
      cni_hash       = "1d9788b0f5420e1a219aad2cb8681823fc515e7c"
      cni_file_name  = "cni-0799f5732f2a11b329d9e3d51b9c8f2e3759f2ff.tar.gz"
      utils_hash     = "aad29883ed2ad2288f708487e1217c079604e9ef"
      protokube_hash = "439b34ab45d5dbe309c7235890ec753e1f6bd9a1"
      ami_name       = "k8s-1.8-debian-jessie-amd64-hvm-ebs-2018-03-11"
      docker_version = "1.13.1"
    }

    "1.8.4" = {
      kubelet_hash   = "125993c220d1a9b5b60ad20a867a0e7cda63e64c"
      kubectl_hash   = "8e2314db816b9b4465c5f713c1152cb0603db15e"
      cni_hash       = "1d9788b0f5420e1a219aad2cb8681823fc515e7c"
      cni_file_name  = "cni-0799f5732f2a11b329d9e3d51b9c8f2e3759f2ff.tar.gz"
      utils_hash     = "aad29883ed2ad2288f708487e1217c079604e9ef"
      protokube_hash = "439b34ab45d5dbe309c7235890ec753e1f6bd9a1"
      ami_name       = "k8s-1.8-debian-jessie-amd64-hvm-ebs-2018-03-11"
      docker_version = "1.13.1"
    }

    "1.8.0" = {
      kubelet_hash   = "4c7b8aafe652ae107c9131754a2ad4e9641a025b"
      kubectl_hash   = "006fd43085e6ba2dc6b35b89af4d68cee3f689c9"
      cni_hash       = "1d9788b0f5420e1a219aad2cb8681823fc515e7c"
      cni_file_name  = "cni-0799f5732f2a11b329d9e3d51b9c8f2e3759f2ff.tar.gz"
      utils_hash     = "aad29883ed2ad2288f708487e1217c079604e9ef"
      protokube_hash = "439b34ab45d5dbe309c7235890ec753e1f6bd9a1"
      ami_name       = "k8s-1.8-debian-jessie-amd64-hvm-ebs-2018-03-11"
      docker_version = "1.13.1"
    }

    "1.7.10" = {
      kubelet_hash   = "4d38bdc8e850c05103348cee2cbffbddce62bcf8"
      kubectl_hash   = "4c174128ad3657bb09c5b3bd4a05565956b44744"
      cni_hash       = "1d9788b0f5420e1a219aad2cb8681823fc515e7c"
      cni_file_name  = "cni-0799f5732f2a11b329d9e3d51b9c8f2e3759f2ff.tar.gz"
      utils_hash     = "aad29883ed2ad2288f708487e1217c079604e9ef"
      protokube_hash = "439b34ab45d5dbe309c7235890ec753e1f6bd9a1"
      ami_name       = "k8s-1.7-debian-jessie-amd64-hvm-ebs-2017-12-02"
      docker_version = "1.12.6"
    }
  }
}

locals {
  k8s_settings = "${local.k8s_versions["${var.kubernetes_version}"]}"
}

locals {
  kubelet_hash   = "${local.k8s_settings["kubelet_hash"]}"
  kubectl_hash   = "${local.k8s_settings["kubectl_hash"]}"
  cni_hash       = "${local.k8s_settings["cni_hash"]}"
  cni_file_name  = "${local.k8s_settings["cni_file_name"]}"
  utils_hash     = "${local.k8s_settings["utils_hash"]}"
  protokube_hash = "${local.k8s_settings["protokube_hash"]}"
  ami_name       = "${local.k8s_settings["ami_name"]}"
  docker_version = "${local.k8s_settings["docker_version"]}"
}
