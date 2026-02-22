#variables for VPC peering demo
variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "staging" # Optional
}
variable "primary_region" {
  description = "The primary region for the first VPC"
  type        = string
  default     = "us-east-1"
}

variable "secondary_region" {
  description = "The secondary region for the second VPC"
  type        = string
  default     = "us-west-2"
}

variable "primary_vpc_cidr" {
  description = "CIDR block for the primary VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "secondary_vpc_cidr" {
  description = "CIDR block for the secondary VPC"
  type        = string
  default     = "10.1.0.0/16"
}

variable "primary_subnet_cidr" {
  description = "CIDR block for the primary subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "secondary_subnet_cidr" {
  description = "CIDR block for the secondary subnet"
  type        = string
  default     = "10.1.1.0/24"
}

variable "instance_type" {
  description = "EC2 instance type for the demo"
  type        = string
  default     = "t3.micro"
}

variable "primary_key_name" {
  description = "Key pair name for the primary region"
  type        = string
  default     = "primary-key"
}

variable "secondary_key_name" {
  description = "Key pair name for the secondary region"
  type        = string
  default     = "secondary-key"
}



