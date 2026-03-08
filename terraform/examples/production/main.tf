# Production Example - Full Enterprise Landing Zone
# This example sets up a complete multi-account landing zone

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }

  backend "s3" {
    # Configure backend for remote state
    # bucket         = "terraform-state-bucket"
    # key            = "landing-zone/terraform.tfstate"
    # region         = "us-east-1"
    # encrypt        = true
    # dynamodb_table = "terraform-locks"
  }
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Environment = "Production"
      Project     = "EnterpriseLandingZone"
      ManagedBy   = "Terraform"
      CostCenter  = "IT-Infrastructure"
    }
  }
}

# =============================================================================
# Full Enterprise Landing Zone
# =============================================================================

module "landing_zone_production" {
  source = "../"

  # Organization
  create_organization = false # Run from management account with existing org

  # Organizational Units
  create_security_ou        = true
  create_infrastructure_ou  = true
  create_workloads_ou       = true
  create_shared_services_ou = true

  # Account Creation (provide unique emails for each)
  create_security_account     = true
  create_log_archive_account  = true
  create_infrastructure_account = true
  create_production_account   = true
  create_non_production_account = true

  # IMPORTANT: Replace with actual unique email addresses
  # Each AWS account needs a unique email
  security_account_email      = "aws-security+YOURDOMAIN@example.com"
  log_archive_account_email   = "aws-logs+YOURDOMAIN@example.com"
  infrastructure_account_email = "aws-infra+YOURDOMAIN@example.com"
  production_account_email    = "aws-prod+YOURDOMAIN@example.com"
  non_production_account_email = "aws-dev+YOURDOMAIN@example.com"

  # Networking
  security_vpc_cidr   = "10.0.0.0/16"
  production_vpc_cidr = "10.1.0.0/16"

  enable_nat_gateway     = true
  create_database_subnets = true
  enable_flow_logs       = true

  # Security Controls - SCPs
  enable_scp_deny_leave_org    = true
  enable_scp_require_mfa       = true
  enable_scp_deny_regions      = true
  denied_regions               = ["ap-northeast-3", "af-south-1"] # Add regions to deny
  enable_scp_enable_cloudtrail = true

  # Security Services
  enable_guardduty           = true
  enable_security_hub        = true
  enable_cis_standards       = true
  enable_foundational_standards = true
  enable_config              = true

  # Logging
  cloudtrail_bucket_name   = null # Auto-generated
  logs_bucket_name         = null # Auto-generated
  create_kms_key           = true
  enable_cloudwatch_logs   = true
  cloudwatch_retention_days = 365
  create_cloudtrail        = true
  cloudtrail_name          = "enterprise-trail"
  enable_data_events       = true # S3 object-level logging
  create_sns_topic         = true

  # Lifecycle Policy
  enable_lifecycle_policy   = true
  ia_transition_days        = 90
  glacier_transition_days   = 180
  expiration_days           = 2555 # 7 years for compliance
}

# =============================================================================
# Outputs
# =============================================================================

output "organization_id" {
  description = "AWS Organization ID"
  value       = module.landing_zone_production.organization_id
}

output "account_ids" {
  description = "Map of account IDs"
  value       = module.landing_zone_production.account_ids
  sensitive   = true
}

output "security_ou_id" {
  description = "Security OU ID"
  value       = module.landing_zone_production.security_ou_id
}

output "production_vpc_id" {
  description = "Production VPC ID"
  value       = module.landing_zone_production.production_vpc_id
}

output "cloudtrail_bucket_arn" {
  description = "CloudTrail Bucket ARN"
  value       = module.landing_zone_production.cloudtrail_bucket_arn
}

output "guardduty_detector_id" {
  description = "GuardDuty Detector ID"
  value       = module.landing_zone_production.guardduty_detector_id
}

output "securityhub_account_id" {
  description = "Security Hub Account ID"
  value       = module.landing_zone_production.securityhub_account_id
}

output "config_recorder_name" {
  description = "AWS Config Recorder Name"
  value       = module.landing_zone_production.config_recorder_name
}
