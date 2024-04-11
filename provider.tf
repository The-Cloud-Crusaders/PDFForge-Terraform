terraform {
    required_providers {
        aws = {
        source  = "hashicorp/aws"
        version = "~> 3.0"
        }
    }
}

provider "aws" {
    region = "ca-central-1"
}

terraform {
  backend "s3" {
    bucket = "devops-project-terraform-remote-backend"
    key    = "pdfforge"
    region = "ca-central-1"
  }
}
