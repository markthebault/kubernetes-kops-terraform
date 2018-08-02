terraform {
  required_version = ">= 0.11.2"
}


provider "aws" {
  version             = "~> 1.15.0"
  region              = "${var.region}"
}