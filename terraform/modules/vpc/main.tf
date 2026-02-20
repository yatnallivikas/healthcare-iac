// Placeholder module describing how networking would be modeled.
locals {
  vpc_id = "vpc-PLACEHOLDER"
  public_subnet_ids = [
    "subnet-public-a",
    "subnet-public-b"
  ]
  private_subnet_ids = [
    "subnet-private-a",
    "subnet-private-b"
  ]
}

# TODO: Implement aws_vpc, aws_subnet, and related resources.
