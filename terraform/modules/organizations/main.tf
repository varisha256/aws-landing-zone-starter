# AWS Organizations Module
# Creates organizational structure with OUs and accounts

resource "aws_organizations_organization" "main" {
  count = var.create_organization ? 1 : 0

  aws_service_access_principals = [
    "cloudtrail.amazonaws.com",
    "config.amazonaws.com",
    "guardduty.amazonaws.com",
    "securityhub.amazonaws.com",
    "backup.amazonaws.com"
  ]

  feature_set = "ALL"
}

resource "aws_organizations_organizational_unit" "security" {
  count      = var.create_security_ou ? 1 : 0
  name       = var.security_ou_name
  parent_id  = var.organization_id != null ? var.organization_id : aws_organizations_organization.main[0].id
}

resource "aws_organizations_organizational_unit" "infrastructure" {
  count      = var.create_infrastructure_ou ? 1 : 0
  name       = var.infrastructure_ou_name
  parent_id  = var.organization_id != null ? var.organization_id : aws_organizations_organization.main[0].id
}

resource "aws_organizations_organizational_unit" "workloads" {
  count      = var.create_workloads_ou ? 1 : 0
  name       = var.workloads_ou_name
  parent_id  = var.organization_id != null ? var.organization_id : aws_organizations_organization.main[0].id
}

resource "aws_organizations_organizational_unit" "shared_services" {
  count      = var.create_shared_services_ou ? 1 : 0
  name       = var.shared_services_ou_name
  parent_id  = var.organization_id != null ? var.organization_id : aws_organizations_organization.main[0].id
}

# Security Account
resource "aws_organizations_account" "security" {
  count     = var.create_security_account ? 1 : 0
  name      = var.security_account_name
  email     = var.security_account_email
  parent_id = var.create_security_ou ? aws_organizations_organizational_unit.security[0].id : (var.organization_id != null ? var.organization_id : aws_organizations_organization.main[0].id)
  role_name = var.admin_role_name
  tags = merge(var.tags, {
    Environment = "Security"
    Purpose     = "Security and Compliance"
  })
}

# Log Archive Account
resource "aws_organizations_account" "log_archive" {
  count     = var.create_log_archive_account ? 1 : 0
  name      = var.log_archive_account_name
  email     = var.log_archive_account_email
  parent_id = var.create_security_ou ? aws_organizations_organizational_unit.security[0].id : (var.organization_id != null ? var.organization_id : aws_organizations_organization.main[0].id)
  role_name = var.admin_role_name
  tags = merge(var.tags, {
    Environment = "LogArchive"
    Purpose     = "Centralized Logging"
  })
}

# Infrastructure Account
resource "aws_organizations_account" "infrastructure" {
  count     = var.create_infrastructure_account ? 1 : 0
  name      = var.infrastructure_account_name
  email     = var.infrastructure_account_email
  parent_id = var.create_infrastructure_ou ? aws_organizations_organizational_unit.infrastructure[0].id : (var.organization_id != null ? var.organization_id : aws_organizations_organization.main[0].id)
  role_name = var.admin_role_name
  tags = merge(var.tags, {
    Environment = "Infrastructure"
    Purpose     = "Shared Infrastructure"
  })
}

# Production Account
resource "aws_organizations_account" "production" {
  count     = var.create_production_account ? 1 : 0
  name      = var.production_account_name
  email     = var.production_account_email
  parent_id = var.create_workloads_ou ? aws_organizations_organizational_unit.workloads[0].id : (var.organization_id != null ? var.organization_id : aws_organizations_organization.main[0].id)
  role_name = var.admin_role_name
  tags = merge(var.tags, {
    Environment = "Production"
    Purpose     = "Production Workloads"
  })
}

# Non-Production Account
resource "aws_organizations_account" "non_production" {
  count     = var.create_non_production_account ? 1 : 0
  name      = var.non_production_account_name
  email     = var.non_production_account_email
  parent_id = var.create_workloads_ou ? aws_organizations_organizational_unit.workloads[0].id : (var.organization_id != null ? var.organization_id : aws_organizations_organization.main[0].id)
  role_name = var.admin_role_name
  tags = merge(var.tags, {
    Environment = "NonProduction"
    Purpose     = "Development and Testing"
  })
}
