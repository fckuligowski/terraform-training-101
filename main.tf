#
# DO NOT DELETE THESE LINES UNTIL INSTRUCTED TO!
#
# Your AMI ID is:
#
#     ami-0135f076a31aebe66
#
# Your subnet ID is:
#
#     subnet-03c92b0d115278403
#
# Your VPC security group ID is:
#
#     sg-0b2501f3da864f94c
#
# Your Identity is:
#
#     amy-training-env-ant
#
variable "access_key" {}
variable "secret_key" {}
variable "region" {
  default = "us-west-2"
}
#variable "ami" {}
variable "subnet_id" {}
variable "identity" {}
variable "vpc_security_group_ids" {
  type = list
}

provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

module "server" {
  source = "./server"

  #  ami = var.ami
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.vpc_security_group_ids
  identity               = var.identity
  key_name               = module.keypair.key_name
  private_key            = module.keypair.private_key_pem
}

module "keypair" {
  source  = "mitchellh/dynamic-keys/aws"
  version = "2.0.0"
  path    = "${path.root}/keys"
  name    = "${var.identity}-key"
}

output "public_ip" {
  value = module.server.public_ip
}

output "public_dns" {
  value = module.server.public_dns
}