provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket = "mike-webapp-blog"
    key    = "terraform/prod/terraform.tfstate"
    region = "eu-central-1"
  }
}

resource "aws_default_vpc" "default" {}

data "aws_ami" "latest_ubuntu" {
  owners      = ["099720109477"]
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server*"]
  }
}
/*
data "aws_arn" "s3_webapp_blog" {
  arn = "arn:aws:s3::mike-webapp-blog"
}
*/
data "aws_route53_zone" "webapp_blog" {
  name = "blog-soloma70.pp.ua."
}

resource "aws_key_pair" "webapp_blog" {
  key_name   = "WebApp-Blog-Key"
  public_key = file("./.cred/app_aws.pub")
}

resource "aws_eip" "webapp_blog" {
  vpc      = true
  instance = aws_instance.webapp_blog.id
  tags = merge(var.common_tags, { Name = "IP-WebApp-${var.common_tags["Env"]}" })
}

resource "aws_route53_record" "www_webapp_blog" {
  zone_id = data.aws_route53_zone.webapp_blog.zone_id
  name    = "www.${data.aws_route53_zone.webapp_blog.name}"
  type    = "A"
  ttl     = "300"
  records = [aws_eip.webapp_blog.public_ip]
  depends_on = [aws_eip.webapp_blog]
}

resource "aws_route53_record" "webapp_blog" {
  zone_id = data.aws_route53_zone.webapp_blog.zone_id
  name    = data.aws_route53_zone.webapp_blog.name
  type    = "A"
  ttl     = "300"
  records = [aws_eip.webapp_blog.public_ip]
  depends_on = [aws_eip.webapp_blog]
}

resource "aws_instance" "webapp_blog" {
  ami                    = data.aws_ami.latest_ubuntu.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.webapp_blog.id]
  key_name               = aws_key_pair.webapp_blog.key_name
  monitoring             = var.enable_detailed_monitoring
  depends_on             = [aws_key_pair.webapp_blog]

  tags = merge(var.common_tags, { Name = "WebApp-${var.common_tags["Env"]}" })
}



resource "aws_security_group" "webapp_blog" {
  name   = "SG WebApp Blog"
  vpc_id = aws_default_vpc.default.id

  dynamic "ingress" {
    for_each = var.allow_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, { Name = "SG-WebApp-${var.common_tags["Env"]}" })
}
