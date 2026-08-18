# STEP 1b: Points Terraform at the state bucket/table created by CloudFormation.
# Replace <ACCOUNT_ID> with your AWS account ID.
terraform {
  required_version = ">= 1.5.0"

  backend "s3" {
    bucket         = "devops-pipeline-tf-state-167667034424"
    key            = "devops-pipeline/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "devops-pipeline-tf-lock"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
