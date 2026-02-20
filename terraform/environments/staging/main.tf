// Dummy-safe staging environment definition for CI validation only.
locals {
  environment = "staging"
  notes       = "TODO: Replace with modules that wire staging infra once AWS access is available."
}

resource "null_resource" "staging_placeholder" {
  triggers = {
    environment = local.environment
    description = "Placeholder resource to keep terraform plan happy."
  }
}

output "staging_placeholder_summary" {
  value       = "Staging plan executed with ${null_resource.staging_placeholder.triggers.environment} placeholder"
  description = "Temporary output so plan has something to emit."
}
