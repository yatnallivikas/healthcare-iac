terraform {
  backend "local" {
    // TODO: replace with remote backend such as S3 + DynamoDB for production state locking
    path = "terraform.tfstate"
  }
}
