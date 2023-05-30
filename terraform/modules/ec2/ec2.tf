variable "stack_name" {
  type = string
}

variable "ami_name" {
  type = string
}

variable "instance_name" {
  type    = string
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "ebs_size" {
  type = number
}

variable "vpc_id" {
  type = string
}

variable "vpc_public_subnet_id" {
  type = string
}

data "aws_availability_zones" "available" {}

data "aws_ami" "image" {
  most_recent = true

  filter {
    name   = "name"
    values = [var.ami_name]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  owners = ["099720109477"] # Canonical
}

########################
#
# Creating EC2 instances
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
#
########################

resource "tls_private_key" "ec2_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ec2_key_pair" {
  key_name   = "${var.stack_name}-${var.instance_name}-${terraform.workspace}"
  public_key = tls_private_key.ec2_private_key.public_key_openssh

  tags = {
    Name        = "${var.stack_name}-${var.instance_name}"
    Environment = terraform.workspace
  }

  provisioner "local-exec" {    # Generate "terraform-key-pair.pem" in current directory
    command = <<-EOT
      echo '${tls_private_key.ec2_private_key.private_key_pem}' > ./.artifacts/keys/'${var.stack_name}-${var.instance_name}-${terraform.workspace}'.pem
    EOT
  }
}

resource "aws_security_group" "ec2_security_group" {
  name   = "${var.stack_name}-${var.instance_name}-${terraform.workspace}-ec2-security-group"
  vpc_id = var.vpc_id

  tags = {
    Name        = "${var.stack_name}-${var.instance_name}"
    Environment = terraform.workspace
  }

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ec2" {
  ami                                  = data.aws_ami.image.id
  instance_type                        = var.instance_type
  availability_zone                    = data.aws_availability_zones.available.names[0]
  key_name                             = aws_key_pair.ec2_key_pair.key_name
  associate_public_ip_address          = true
  disable_api_termination              = true
  instance_initiated_shutdown_behavior = "stop"
  vpc_security_group_ids               = [aws_security_group.ec2_security_group.id]
  subnet_id                            = var.vpc_public_subnet_id

  tags = {
    Name        = "${var.stack_name}-${var.instance_name}"
    Environment = terraform.workspace
  }

  root_block_device {
    tags = {
      Name        = "${var.stack_name}-${var.instance_name}-root"
      Environment = terraform.workspace
    }
  }

  ebs_block_device {
    device_name           = "/dev/sdf"
    delete_on_termination = false
    iops                  = 3000
    volume_size           = var.ebs_size
    volume_type           = "gp3"
    throughput            = 125

    tags = {
      Name        = "${var.stack_name}-${var.instance_name}"
      Environment = terraform.workspace
    }
  }
}
