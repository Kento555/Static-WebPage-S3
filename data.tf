# Using data source to fetch public & Private subnet automatically , do not know the public subnet ID
data "aws_subnets" "public_subnets" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
  filter {
    name   = "tag:Name"
    values = ["*public*"] # This will match any subnet with "public" in its Name tag.
  }
}


data "aws_subnets" "private_subnets" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id] 
  }
  filter {
    name   = "tag:Name"
    values = ["*private*"] # This will match any subnet with "private" in its Name tag.
  }
}


data "aws_ami" "latest_amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}


data "aws_key_pair" "ws_keypair" {
  key_name           = "weishen-keypair"  # *** This is my keypair.
  include_public_key = true               # Fetches the public key along with the key pair details.
}


output "public_subnet_ids" {
  value = data.aws_subnets.public_subnets.ids
}

output "private_subnet_ids" {
  value = data.aws_subnets.private_subnets.ids
}
