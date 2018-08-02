resource "tls_private_key" "private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "${var.key_name}"
  public_key = "${tls_private_key.private_key.public_key_openssh}"
}

resource "null_resource" "k8s" {
  triggers {
    private_key = "${tls_private_key.private_key.private_key_pem}"
  }

  provisioner "local-exec" {
    command = "terraform output private_key > ${path.module}/key.pem"
  }
}
