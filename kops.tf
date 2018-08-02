module "kops" {
  source               = "modules/tf-kops-cluster"
  sg_allow_ssh         = "${aws_security_group.allow_ssh.id}"
  sg_allow_http_s      = "${aws_security_group.allow_http.id}"
  cluster_name         = "${var.cluster_name}"
  cluster_fqdn         = "${var.cluster_name}.${aws_route53_zone.main.name}"
  route53_zone_id      = "${aws_route53_zone.main.id}"
  kops_s3_bucket_arn   = "${aws_s3_bucket.kops.arn}"
  kops_s3_bucket_id    = "${aws_s3_bucket.kops.id}"
  vpc_id               = "${module.vpc.vpc_id}"
  instance_key_name    = "${aws_key_pair.generated_key.key_name}"
  internet_gateway_id  = "${module.vpc.igw_id}"
  master_instance_type = "t2.medium"
  node_instance_type   = "t2.medium"
  kubernetes_version   = "${var.kubernetes_version}"
  kops_dns_mode        = "private"

  public_subnet_cidr_blocks = "${var.kubernetes_public_subnets_cidr}" #For the LB
  private_subnet_ids        = "${module.vpc.private_subnets}"
}

resource "random_id" "s3_suffix" {
  byte_length = 3
}

resource "aws_s3_bucket" "kops" {
  bucket        = "${var.env}-kops-state-store-${random_id.s3_suffix.dec}"
  acl           = "private"
  force_destroy = true

  versioning {
    enabled = true
  }
}


resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  vpc_id      = "${module.vpc.vpc_id}"
  description = "Allows SSH access from everywhere"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "allow_ssh"
  }
}

resource "aws_security_group" "allow_http" {
  name        = "allow_http_s"
  vpc_id      = "${module.vpc.vpc_id}"
  description = "Allows HTTP/S access from everywhere"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "allow_http"
  }
}
