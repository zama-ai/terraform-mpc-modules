data "aws_region" "current" {}

resource "aws_eip" "kubeip" {
  // default EIP limit is 5 (make sure to increase it if you need more)
  count = var.number_of_ips

  tags = merge({
    Name        = "${var.name}-${count.index}"
  }, var.tags)
}