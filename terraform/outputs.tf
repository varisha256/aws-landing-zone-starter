# =============================================================================
# Organization Outputs
# =============================================================================

output "organization_id" {
  description = "AWS Organization ID"
  value       = module.organizations.organization_id
}

output "security_ou_id" {
  description = "Security OU ID"
  value       = module.organizations.security_ou_id
}

output "infrastructure_ou_id" {
  description = "Infrastructure OU ID"
  value       = module.organizations.infrastructure_ou_id
}

output "workloads_ou_id" {
  description = "Workloads OU ID"
  value       = module.organizations.workloads_ou_id
}

output "shared_services_ou_id" {
  description = "Shared Services OU ID"
  value       = module.organizations.shared_services_ou_id
}

output "account_ids" {
  description = "Map of all account IDs"
  value       = module.organizations.account_ids
}

# =============================================================================
# Networking Outputs
# =============================================================================

output "security_vpc_id" {
  description = "Security account VPC ID"
  value       = module.networking_security.vpc_id
}

output "security_private_subnet_ids" {
  description = "Security account private subnet IDs"
  value       = module.networking_security.private_subnet_ids
}

output "production_vpc_id" {
  description = "Production account VPC ID"
  value       = module.networking_production.vpc_id
}

output "production_private_subnet_ids" {
  description = "Production account private subnet IDs"
  value       = module.networking_production.private_subnet_ids
}

# =============================================================================
# Security Outputs
# =============================================================================

output "guardduty_detector_id" {
  description = "GuardDuty Detector ID"
  value       = module.security.guardduty_detector_id
}

output "securityhub_account_id" {
  description = "Security Hub Account ID"
  value       = module.security.securityhub_account_id
}

output "config_recorder_name" {
  description = "AWS Config Recorder Name"
  value       = module.security.config_recorder_name
}

# =============================================================================
# Logging Outputs
# =============================================================================

output "cloudtrail_bucket_arn" {
  description = "CloudTrail S3 Bucket ARN"
  value       = module.logging.cloudtrail_bucket_arn
}

output "cloudtrail_id" {
  description = "CloudTrail ID"
  value       = module.logging.cloudtrail_id
}

output "logs_bucket_arn" {
  description = "Central Logs S3 Bucket ARN"
  value       = module.logging.logs_bucket_arn
}

output "kms_key_arn" {
  description = "KMS Key ARN for CloudTrail encryption"
  value       = module.logging.kms_key_arn
}

output "sns_topic_arn" {
  description = "SNS Topic ARN for CloudTrail notifications"
  value       = module.logging.sns_topic_arn
}
