terraform {
  required_version = ">=1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.0.0"
    }
  }
}

#provider for the primary region
provider "aws" {
  region = var.primary_region
  alias  = "primary"
}

#provider for the secondary region
provider "aws" {
  region = var.secondary_region
  alias  = "secondary"
}

