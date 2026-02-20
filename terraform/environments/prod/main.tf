// Dummy-safe prod environment definition for CI validation only.
locals {
  environment = "prod"
  notes       = "TODO: Wire actual production infrastructure once credentials and approvals are wired."
}

resource "null_resource" "prod_placeholder" {
  triggers = {
    environment = local.environment
    description = "Placeholder resource to keep terraform plan happy."
  }
}

output "prod_placeholder_summary" {
  value       = "Prod plan executed with ${null_resource.prod_placeholder.triggers.environment} placeholder"
  description = "Temporary output so plan has something to emit."
}
