terraform {
  required_providers {
    aws = {
      source    = "hashicorp/aws"
      version   = "5.59.0"
    }
  }
  # Minimum requires version 
    required_version = ">= 1.5.0"

}

provider "aws" {
  # Configuration options
  region = var.region
}