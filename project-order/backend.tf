terraform {
  backend "s3" {
    bucket         = "my-tf-state-bucket-terraform-works"
    key            = "capstone-project/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock-works"
    encrypt        = true
  }
}

