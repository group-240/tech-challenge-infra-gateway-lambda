terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "tech-challenge-tfstate-533267363894-4"
    key            = "gateway/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tech-challenge-terraform-lock-533267363894-4"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
  # Credenciais via AWS CLI profile, variáveis de ambiente ou IAM role
}