#Data Sources for VPC peering demo
#Data source for availability zones in primary region
data "aws_availability_zones" "primary" {
  provider = aws.primary
  state    = "available"

}

#Data source for availability zones in secondary region
data "aws_availability_zones" "secondary" {
  provider = aws.secondary
  state    = "available"

}

#Data source for primary region AMI (Ubuntu)
data "aws_ami" "primary_ami" {
  provider    = aws.primary
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  owners = ["099720109477"] #Canonical
}

#Data source for secondary region AMI (Ubuntu)
data "aws_ami" "secondary_ami" {
  provider    = aws.secondary
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  owners = ["099720109477"] #Canonical
}



