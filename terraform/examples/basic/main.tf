# Basic Example - Security-focused Landing Zone
# This example sets up a minimal landing zone with security controls

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
  region = "us-east-1"

  default_tags {
    tags = {
      Environment = "Basic"
      Project     = "LandingZone"
      ManagedBy   = "Terraform"
    }
  }
}

# Use existing organization - create security controls only
module "landing_zone_basic" {
  source = "../"

  # Use existing organization (run from management account)
  create_organization       = false
  existing_organization_id  = null # Will use existing org

  # Disable account creation (use existing accounts)
  create_security_account     = false
  create_log_archive_account  = false
  create_infrastructure_account = false
  create_production_account   = false
  create_non_production_account = false

  # Enable security controls
  enable_scp_deny_leave_org    = true
  enable_scp_require_mfa       = false
  enable_scp_deny_regions      = false
  enable_scp_enable_cloudtrail = true

  enable_guardduty        = true
  enable_security_hub     = true
  enable_cis_standards    = true
  enable_config           = true

  # Enable logging
  create_cloudtrail       = true
  enable_cloudwatch_logs  = true
  create_kms_key          = true

  # Networking
  enable_nat_gateway      = false # Cost saving for basic setup
  enable_flow_logs        = true
}

output "cloudtrail_bucket_arn" {
  value = module.landing_zone_basic.cloudtrail_bucket_arn
}

output "guardduty_detector_id" {
  value = module.landing_zone_basic.guardduty_detector_id
}

output "securityhub_account_id" {
  value = module.landing_zone_basic.securityhub_account_id
}
