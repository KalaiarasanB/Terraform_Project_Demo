
#VPC Peering Demo
#This demo creates two VPCs in different regions, sets up VPC peering between them, and launches EC2 instances in each VPC to demonstrate connectivity.

#primary VPC in us-east-1
resource "aws_vpc" "primary_vpc" {
  provider             = aws.primary
  cidr_block           = var.primary_vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "Primary-VPC-${var.primary_region}"
    Environment = "Demo"
    Purpose     = "VPC Peering"
  }
}

#Secondary VPC in us-west-2
resource "aws_vpc" "secondary_vpc" {
  provider             = aws.secondary
  cidr_block           = var.secondary_vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "Secondary-VPC-${var.secondary_region}"
    Environment = "Demo"
    Purpose     = "VPC-Peering-Demo"
  }
}

#Subnet in primary VPC
resource "aws_subnet" "primary_subnet" {
  provider                = aws.primary
  vpc_id                  = aws_vpc.primary_vpc.id
  cidr_block              = var.primary_subnet_cidr
  availability_zone       = data.aws_availability_zones.primary.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name        = "Primary-Subnet-${var.primary_region}"
    Environment = "Demo"
    Purpose     = "VPC Peering"
  }
}

#Subnet in secondary VPC
resource "aws_subnet" "secondary_subnet" {
  provider                = aws.secondary
  vpc_id                  = aws_vpc.secondary_vpc.id
  cidr_block              = var.secondary_subnet_cidr
  availability_zone       = data.aws_availability_zones.secondary.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name        = "Secondary-Subnet-${var.secondary_region}"
    Environment = "Demo"
    Purpose     = "VPC Peering"
  }
}

#internet gateway for primary VPC
resource "aws_internet_gateway" "primary_igw" {
  provider = aws.primary
  vpc_id   = aws_vpc.primary_vpc.id

  tags = {
    Name        = "Primary-IGW-${var.primary_region}"
    Environment = "Demo"
    Purpose     = "VPC Peering"
  }

}

#internet gateway for secondary VPC
resource "aws_internet_gateway" "secondary_igw" {
  provider = aws.secondary
  vpc_id   = aws_vpc.secondary_vpc.id

  tags = {
    Name        = "Secondary-IGW-${var.secondary_region}"
    Environment = "Demo"
    Purpose     = "VPC Peering"
  }

}

#route table for primary VPC
resource "aws_route_table" "primary_rt" {
  provider = aws.primary
  vpc_id   = aws_vpc.primary_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.primary_igw.id
  }

  tags = {
    Name        = "Primary-RT-${var.primary_region}"
    Environment = "Demo"
    Purpose     = "VPC Peering"
  }
}

#Route table for secondary VPC
resource "aws_route_table" "secondary_rt" {
  provider = aws.secondary
  vpc_id   = aws_vpc.secondary_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.secondary_igw.id
  }

  tags = {
    Name        = "Secondary-RT-${var.secondary_region}"
    Environment = "Demo"
    Purpose     = "VPC Peering"
  }
}

#Associate route table with primary subnet
resource "aws_route_table_association" "primary_rta" {
  provider       = aws.primary
  subnet_id      = aws_subnet.primary_subnet.id
  route_table_id = aws_route_table.primary_rt.id
}

#Associate route table with secondary subnet
resource "aws_route_table_association" "secondary_rta" {
  provider       = aws.secondary
  subnet_id      = aws_subnet.secondary_subnet.id
  route_table_id = aws_route_table.secondary_rt.id
}

#VPC peering connection (requester side - primary VPC)
resource "aws_vpc_peering_connection" "primary_to_secondary" {

  provider    = aws.primary
  vpc_id      = aws_vpc.primary_vpc.id
  peer_vpc_id = aws_vpc.secondary_vpc.id #distination VPC ID
  peer_region = var.secondary_region
  auto_accept = false

  tags = {
    Name        = "primary-to-secondary-peering"
    Environment = "Demo"
    Side        = "Requester"
  }
}

#VPC peering connection (accepter side - secondary VPC)
resource "aws_vpc_peering_connection_accepter" "secondary_to_primary" {
  provider                  = aws.secondary
  vpc_peering_connection_id = aws_vpc_peering_connection.primary_to_secondary.id
  auto_accept               = true

  tags = {
    Name        = "secondary-to-primary-peering"
    Environment = "Demo"
    Side        = "Accepter"
  }
}

#Route for primary VPC to secondary VPC
resource "aws_route" "primary_to_secondary_route" {
  provider                  = aws.primary
  route_table_id            = aws_route_table.primary_rt.id
  destination_cidr_block    = var.secondary_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.primary_to_secondary.id

  depends_on = [aws_vpc_peering_connection_accepter.secondary_to_primary]
}

#Route for secondary VPC to primary VPC
resource "aws_route" "secondary_to_primary_route" {
  provider                  = aws.secondary
  route_table_id            = aws_route_table.secondary_rt.id
  destination_cidr_block    = var.primary_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.primary_to_secondary.id

  depends_on = [aws_vpc_peering_connection_accepter.secondary_to_primary]
}

#Security Group for Primary VPC
resource "aws_security_group" "primary_sg" {
  provider    = aws.primary
  name        = "primary-sg"
  description = "Security group for primary VPC"
  vpc_id      = aws_vpc.primary_vpc.id

  ingress {
    description = "Allow SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow ICMP from secondary VPC"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.secondary_vpc_cidr]
  }

  ingress {
    description = "Allow all traffic from secondary VPC"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.secondary_vpc_cidr]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "Primary-SG-${var.primary_region}"
    Environment = "Demo"
    Purpose     = "VPC Peering"
  }

}

#Security Group for Secondary VPC
resource "aws_security_group" "secondary_sg" {
  provider    = aws.secondary
  name        = "secondary-sg"
  description = "Security group for secondary VPC"
  vpc_id      = aws_vpc.secondary_vpc.id

  ingress {
    description = "Allow SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow ICMP from primary VPC"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.primary_vpc_cidr]
  }

  ingress {
    description = "Allow all traffic from primary VPC"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.primary_vpc_cidr]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "Secondary-SG-${var.secondary_region}"
    Environment = "Demo"
    Purpose     = "VPC Peering"
  }

}

#EC2 instance in primary VPC
resource "aws_instance" "primary_instance" {
  provider               = aws.primary
  ami                    = data.aws_ami.primary_ami.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.primary_subnet.id
  vpc_security_group_ids = [aws_security_group.primary_sg.id]
  key_name               = var.primary_key_name

  user_data = local.primary_user_data

  tags = {
    "Name"        = "Primary-Instance-${var.primary_region}"
    "Environment" = "Demo"
    "Purpose"     = "VPC Peering"
  }

  depends_on = [aws_vpc_peering_connection_accepter.secondary_to_primary]

}

#eC2 instance in secondary VPC
resource "aws_instance" "secondary_instance" {
  provider               = aws.secondary
  ami                    = data.aws_ami.secondary_ami.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.secondary_subnet.id
  vpc_security_group_ids = [aws_security_group.secondary_sg.id]
  key_name               = var.secondary_key_name

  user_data = local.secondary_user_data

  tags = {
    "Name"        = "Secondary-Instance-${var.secondary_region}"
    "Environment" = "Demo"
    "Purpose"     = "VPC Peering"
  }

  depends_on = [aws_vpc_peering_connection_accepter.secondary_to_primary]


}

