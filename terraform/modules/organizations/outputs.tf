output "organization_id" {
  description = "AWS Organization ID"
  value       = var.organization_id != null ? var.organization_id : aws_organizations_organization.main[0].id
}

output "security_ou_id" {
  description = "Security OU ID"
  value       = try(aws_organizations_organizational_unit.security[0].id, null)
}

output "infrastructure_ou_id" {
  description = "Infrastructure OU ID"
  value       = try(aws_organizations_organizational_unit.infrastructure[0].id, null)
}

output "workloads_ou_id" {
  description = "Workloads OU ID"
  value       = try(aws_organizations_organizational_unit.workloads[0].id, null)
}

output "shared_services_ou_id" {
  description = "Shared Services OU ID"
  value       = try(aws_organizations_organizational_unit.shared_services[0].id, null)
}

output "security_account_id" {
  description = "Security Account ID"
  value       = try(aws_organizations_account.security[0].id, null)
}

output "log_archive_account_id" {
  description = "Log Archive Account ID"
  value       = try(aws_organizations_account.log_archive[0].id, null)
}

output "infrastructure_account_id" {
  description = "Infrastructure Account ID"
  value       = try(aws_organizations_account.infrastructure[0].id, null)
}

output "production_account_id" {
  description = "Production Account ID"
  value       = try(aws_organizations_account.production[0].id, null)
}

output "non_production_account_id" {
  description = "Non-Production Account ID"
  value       = try(aws_organizations_account.non_production[0].id, null)
}

output "account_ids" {
  description = "Map of all created account IDs"
  value = {
    security       = try(aws_organizations_account.security[0].id, null)
    log_archive    = try(aws_organizations_account.log_archive[0].id, null)
    infrastructure = try(aws_organizations_account.infrastructure[0].id, null)
    production     = try(aws_organizations_account.production[0].id, null)
    non_production = try(aws_organizations_account.non_production[0].id, null)
  }
}
