#variable ami {}
variable subnet_id {}
variable vpc_security_group_ids {
  type = list
}
variable identity {}
variable key_name {}
variable private_key {}
variable num_webs {
  default = "2"
}

data "aws_ami" "ubuntu_16_04" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }
  owners = ["099720109477"]
}

resource "aws_instance" "web" {
  count                  = var.num_webs
  ami                    = data.aws_ami.ubuntu_16_04.image_id
  instance_type          = "t2.micro"
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.vpc_security_group_ids
  key_name               = var.key_name

  tags = {
    "Identity"    = var.identity
    "Name"        = "Student ${count.index + 1}/${var.num_webs}"
    "Environment" = "Training"
  }

  connection {
    user        = "ubuntu"
    private_key = var.private_key
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "assets"
    destination = "/tmp"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo sh /tmp/assets/setup-web.sh"
    ]
  }
}


output "public_ip" {
  value = aws_instance.web[*].public_ip
}
output "public_dns" {
  value = aws_instance.web[*].public_dns
}