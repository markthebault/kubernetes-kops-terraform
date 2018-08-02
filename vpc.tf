module "vpc" {
  source                           = "terraform-aws-modules/vpc/aws"
  name                             = "${var.env}"
  cidr                             = "${var.vpc_cidr}"
  azs                              = "${var.AZS}"
  private_subnets                  = "${var.private_subnets}"
  public_subnets                   = "${var.public_subnets}"
  enable_nat_gateway               = true
  enable_s3_endpoint               = true
  enable_dynamodb_endpoint         = true
  enable_dns_support               = true
  enable_dns_hostnames             = true
  tags                             = "${merge(var.tags)}"
  dhcp_options_domain_name         = "${aws_route53_zone.main.zone_id}"
  dhcp_options_domain_name_servers = "${aws_route53_zone.main.name_servers}"
}


resource "aws_route53_zone" "main" {
  name          = "${var.main_domain}"
  force_destroy = true
  tags          = "${merge(var.tags)}"
  vpc_id        = "${module.vpc.vpc_id}"
}
