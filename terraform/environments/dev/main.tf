// Dummy-safe dev environment definition for CI validation only.
locals {
  environment = "dev"
  notes       = "TODO: Replace with actual modules for networking, EKS, and ECR."
}

resource "null_resource" "dev_placeholder" {
  triggers = {
    environment = local.environment
    description = "Placeholder resource to keep terraform plan happy."
  }
}

output "dev_placeholder_summary" {
  value       = "Dev plan executed with ${null_resource.dev_placeholder.triggers.environment} placeholder"
  description = "Temporary output so plan has something to emit."
}
