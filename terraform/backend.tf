terraform {
  backend "s3" {
    bucket         = "my-terraform-states-2025-mahesh"    
    key            = "capstone/dev/terraform.tfstate"  
    region         = "us-east-1"              
    dynamodb_table = "terraform-locks"        
    encrypt        = true                     
  }
}
