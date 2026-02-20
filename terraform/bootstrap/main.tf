resource "aws_s3_bucket" "tf_state" {
  bucket = "vikas-healthcare-tf-state-2026-xyz123"

  tags = {
    Name = "terraform-state"
  }
}

resource "aws_dynamodb_table" "tf_lock" {
  name         = "terraform-lock-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}