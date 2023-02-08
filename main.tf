terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "eu-west-3"
}

resource "aws_instance" "app_server" {
  ami                    = "ami-0afd55c0c8a52973a"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.instance.id]

  user_data = <<-EOF
			  #!/bin/bash
			  echo "Hello, World" > index.html
			  nohup busybox http -f -p ${var.server_port} &
			  EOF

  user_data_replace_on_change = true

  tags = {
    Name = "WebAppServerInstance"
  }
}

resource "aws_security_group" "instance" {
  name = var.security_group_name

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 8080
}

variable "security_group_name" {
  description = "The name of the security group"
  type        = string
  default     = "terraform-WebAppServer-instance"
}

output "public_ip" {
  value       = aws_instance.app_server.public_ip
  description = "The public IP of the WebAppServer Instance"
}