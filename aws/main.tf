provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "watro-terraform-aws-state"
    key    = "terraform.tfstate"
    region = "us-east-1"
    encrypt = true
  }
}

output "public_ip" {
  value = "${aws_instance.example.public_ip}"
}

resource "aws_security_group" "instance" {
  name = "terraform-example-instance"

  egress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_instance" "example" {
  ami = "ami-c481fad3"
  instance_type = "t2.micro"
  iam_instance_profile = "test_profile"
  vpc_security_group_ids = ["${aws_security_group.instance.id}"]

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update
              sudo yum install ruby
              sudo yum install wget
              cd /home/ec2-user
              sudo wget https://aws-codedeploy-us-east-1.s3.amazonaws.com/latest/install
              sudo chmod +x ./install
              sudo ./install auto
              EOF
  tags {
    Name = "terraform-example"
  }
}


resource "aws_iam_instance_profile" "example" {
  name  = "test_profile"
  role = "${aws_iam_role.role.name}"
}

resource "aws_iam_role" "role" {
  name = "test_role"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}
