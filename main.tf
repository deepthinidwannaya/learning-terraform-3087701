data "aws_ami" "app_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["bitnami-tomcat-*-x86_64-hvm-ebs-nami"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["979382823631"] # Bitnami
}

data "aws_vpc" "default" {
  default = true
}

module "blog_sec_grp" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.2"
  name = "blog_new"

  vpc_id = module.blog_vpc.vpc_id

  ingress_rules = ["http-80-tcp", "https-443-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]

  egress_rules = ["all-all"]
  egress_cidr_blocks = ["0.0.0.0/0"]
}

module "blog_vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "dev"
  cidr = "10.0.0.0/16"

  azs             = ["us-west-2a", "us-west-2b", "us-west-2c"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

resource "aws_instance" "blog" {
  ami           = data.aws_ami.app_ami.id
  instance_type = var.instance_type

  vpc_security_group_ids = [module.blog_sec_grp.security_group_id]

  subnet_id = module.blog_vpc.public_subnets[0]

  tags = {
    Name = "HelloWorld"
  }
}

data "aws_vpc" "blog" {
  default = true
}



#resource "aws_security_group" "blog" {
#  name = "blog"
#  description = "Allow http and https in. Allow everything out."
#
#  vpc_id = data.aws_vpc.default.id
#}
#
#resource "aws_security_group_rule" "blog_http_in" {
#  from_port         = 80
#  protocol          = "tcp"
#  cidr_blocks       = ["0.0.0.0/0"]
#  to_port           = 80
#  type              = "ingress"
#
#  security_group_id = aws_security_group.blog.id
#}
#
#resource "aws_security_group_rule" "blog_https_in" {
#  from_port         = 443
#  protocol          = "tcp"
#  cidr_blocks       = ["0.0.0.0/0"]
#  to_port           = 443
#  type              = "ingress"
#
#  security_group_id = aws_security_group.blog.id
#}
#
#resource "aws_security_group_rule" "blog_everything_out" {
#  from_port         = 0
#  protocol          = -1
#  cidr_blocks       = ["0.0.0.0/0"]
#  to_port           = 0
#  type              = "egress"
#
#  security_group_id = aws_security_group.blog.id
#}
