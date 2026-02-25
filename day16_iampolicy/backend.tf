terraform {
    backend "s3" {
      bucket = "my-terraform-state-bucket-kalaiarasanbalu-963258741"
      key    = "terraform.tfstate"
      region = "us-east-1"
    }
}

