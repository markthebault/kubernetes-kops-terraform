resource "aws_instance" "bastion" {
  instance_type               = "t2.micro"
  ami                         = "ami-466768ac"
  tags                        = "${merge(var.tags,map("Name", format("%s", "Bastion")))}"
  key_name                    = "${aws_key_pair.generated_key.key_name}"
  subnet_id                   = "${module.vpc.public_subnets[0]}"
  associate_public_ip_address = true
  vpc_security_group_ids      = ["${aws_security_group.bastion.id}"]

  user_data = <<EOF
#cloud-config
runcmd:
- curl -LO https://storage.googleapis.com/kubernetes-release/release/v${var.kubernetes_version}/bin/linux/amd64/kubectl
- chmod 0777 ./kubectl
- mv ./kubectl /usr/local/bin/

EOF
}


resource "aws_security_group" "bastion" {
  name                   = "sg_${var.env}_bastion"
  vpc_id                 = "${module.vpc.vpc_id}"
  revoke_rules_on_delete = true

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = "0.0.0.0/0"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${merge(var.tags)}"
}

resource "aws_eip" "bastion" {
  instance = "${aws_instance.bastion.id}"
}