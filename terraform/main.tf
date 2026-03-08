terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = var.default_tags
  }
}

# =============================================================================
# AWS Organizations & Account Structure
# =============================================================================

module "organizations" {
  source = "./modules/organizations"

  # Organization
  create_organization = var.create_organization
  organization_id     = var.existing_organization_id

  # Organizational Units
  create_security_ou        = var.create_security_ou
  create_infrastructure_ou  = var.create_infrastructure_ou
  create_workloads_ou       = var.create_workloads_ou
  create_shared_services_ou = var.create_shared_services_ou

  # Accounts
  create_security_account     = var.create_security_account
  create_log_archive_account  = var.create_log_archive_account
  create_infrastructure_account = var.create_infrastructure_account
  create_production_account   = var.create_production_account
  create_non_production_account = var.create_non_production_account

  # Account Emails (Required for account creation)
  security_account_email      = var.security_account_email
  log_archive_account_email   = var.log_archive_account_email
  infrastructure_account_email = var.infrastructure_account_email
  production_account_email    = var.production_account_email
  non_production_account_email = var.non_production_account_email

  tags = var.default_tags
}

# =============================================================================
# Networking (Deployed in each account as needed)
# =============================================================================

module "networking_security" {
  source = "./modules/networking"

  environment = "security"

  vpc_cidr             = var.security_vpc_cidr
  enable_nat_gateway   = var.enable_nat_gateway
  create_database_subnets = false
  enable_flow_logs     = var.enable_flow_logs

  tags = merge(var.default_tags, {
    Account = "Security"
  })

  depends_on = [module.organizations]
}

module "networking_production" {
  source = "./modules/networking"

  environment = "production"

  vpc_cidr             = var.production_vpc_cidr
  enable_nat_gateway   = var.enable_nat_gateway
  create_database_subnets = var.create_database_subnets
  enable_flow_logs     = var.enable_flow_logs

  tags = merge(var.default_tags, {
    Account = "Production"
  })

  depends_on = [module.organizations]
}

# =============================================================================
# Security Controls
# =============================================================================

module "security" {
  source = "./modules/security"

  environment  = "security"
  region       = var.region
  target_ou_id = module.organizations.security_ou_id

  # SCPs
  create_scp_deny_leave_org    = var.enable_scp_deny_leave_org
  create_scp_require_mfa       = var.enable_scp_require_mfa
  create_scp_deny_regions      = var.enable_scp_deny_regions
  denied_regions               = var.denied_regions
  create_scp_enable_cloudtrail = var.enable_scp_enable_cloudtrail

  # GuardDuty
  enable_guardduty            = var.enable_guardduty
  guardduty_admin_account_id  = module.organizations.security_account_id

  # Security Hub
  enable_security_hub              = var.enable_security_hub
  security_hub_admin_account_id    = module.organizations.security_account_id
  enable_cis_standards             = var.enable_cis_standards
  enable_foundational_standards    = var.enable_foundational_standards

  # AWS Config
  enable_config           = var.enable_config
  create_config_bucket    = true

  tags = var.default_tags

  depends_on = [module.organizations]
}

# =============================================================================
# Centralized Logging
# =============================================================================

module "logging" {
  source = "./modules/logging"

  environment = "security"

  # Buckets
  cloudtrail_bucket_name = var.cloudtrail_bucket_name
  logs_bucket_name       = var.logs_bucket_name

  # KMS
  create_kms_key = var.create_kms_key

  # CloudWatch
  enable_cloudwatch_logs  = var.enable_cloudwatch_logs
  cloudwatch_retention_days = var.cloudwatch_retention_days

  # CloudTrail
  create_cloudtrail  = var.create_cloudtrail
  cloudtrail_name    = var.cloudtrail_name
  enable_data_events = var.enable_data_events

  # SNS
  create_sns_topic = var.create_sns_topic

  # Lifecycle
  enable_lifecycle_policy   = var.enable_lifecycle_policy
  ia_transition_days        = var.ia_transition_days
  glacier_transition_days   = var.glacier_transition_days
  expiration_days           = var.expiration_days

  tags = var.default_tags

  depends_on = [module.organizations]
}
