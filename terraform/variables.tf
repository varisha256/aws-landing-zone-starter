# =============================================================================
# General Configuration
# =============================================================================

variable "region" {
  description = "AWS Region for deploying resources"
  type        = string
  default     = "us-east-1"
}

variable "default_tags" {
  description = "Default tags to apply to all resources"
  type        = map(string)
  default = {
    ManagedBy   = "Terraform"
    Project     = "LandingZone"
  }
}

# =============================================================================
# Organization Configuration
# =============================================================================

variable "create_organization" {
  description = "Create a new AWS Organization (set false if using existing)"
  type        = bool
  default     = false
}

variable "existing_organization_id" {
  description = "Existing AWS Organization ID"
  type        = string
  default     = null
}

variable "create_security_ou" {
  description = "Create Security Organizational Unit"
  type        = bool
  default     = true
}

variable "create_infrastructure_ou" {
  description = "Create Infrastructure Organizational Unit"
  type        = bool
  default     = true
}

variable "create_workloads_ou" {
  description = "Create Workloads Organizational Unit"
  type        = bool
  default     = true
}

variable "create_shared_services_ou" {
  description = "Create Shared Services Organizational Unit"
  type        = bool
  default     = true
}

# =============================================================================
# Account Configuration
# =============================================================================

variable "create_security_account" {
  description = "Create dedicated Security account"
  type        = bool
  default     = true
}

variable "create_log_archive_account" {
  description = "Create dedicated Log Archive account"
  type        = bool
  default     = true
}

variable "create_infrastructure_account" {
  description = "Create dedicated Infrastructure account"
  type        = bool
  default     = false
}

variable "create_production_account" {
  description = "Create dedicated Production account"
  type        = bool
  default     = true
}

variable "create_non_production_account" {
  description = "Create dedicated Non-Production account"
  type        = bool
  default     = true
}

# Account Emails (REQUIRED if creating accounts)
variable "security_account_email" {
  description = "Email for Security account (must be unique AWS account email)"
  type        = string
  default     = ""
}

variable "log_archive_account_email" {
  description = "Email for Log Archive account"
  type        = string
  default     = ""
}

variable "infrastructure_account_email" {
  description = "Email for Infrastructure account"
  type        = string
  default     = ""
}

variable "production_account_email" {
  description = "Email for Production account"
  type        = string
  default     = ""
}

variable "non_production_account_email" {
  description = "Email for Non-Production account"
  type        = string
  default     = ""
}

# =============================================================================
# Networking Configuration
# =============================================================================

variable "security_vpc_cidr" {
  description = "CIDR block for Security account VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "production_vpc_cidr" {
  description = "CIDR block for Production account VPC"
  type        = string
  default     = "10.1.0.0/16"
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = true
}

variable "create_database_subnets" {
  description = "Create dedicated database subnets"
  type        = bool
  default     = true
}

variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs"
  type        = bool
  default     = true
}

# =============================================================================
# Security Configuration
# =============================================================================

variable "enable_scp_deny_leave_org" {
  description = "Enable SCP to deny leaving organization"
  type        = bool
  default     = true
}

variable "enable_scp_require_mfa" {
  description = "Enable SCP to require MFA"
  type        = bool
  default     = false
}

variable "enable_scp_deny_regions" {
  description = "Enable SCP to deny specific regions"
  type        = bool
  default     = false
}

variable "denied_regions" {
  description = "List of AWS regions to deny"
  type        = list(string)
  default     = []
}

variable "enable_scp_enable_cloudtrail" {
  description = "Enable SCP to require CloudTrail"
  type        = bool
  default     = true
}

variable "enable_guardduty" {
  description = "Enable GuardDuty"
  type        = bool
  default     = true
}

variable "enable_security_hub" {
  description = "Enable Security Hub"
  type        = bool
  default     = true
}

variable "enable_cis_standards" {
  description = "Enable CIS AWS Foundations Benchmark"
  type        = bool
  default     = true
}

variable "enable_foundational_standards" {
  description = "Enable AWS Foundational Security Best Practices"
  type        = bool
  default     = true
}

variable "enable_config" {
  description = "Enable AWS Config"
  type        = bool
  default     = true
}

# =============================================================================
# Logging Configuration
# =============================================================================

variable "cloudtrail_bucket_name" {
  description = "Name of S3 bucket for CloudTrail logs"
  type        = string
  default     = null
}

variable "logs_bucket_name" {
  description = "Name of S3 bucket for general logs"
  type        = string
  default     = null
}

variable "create_kms_key" {
  description = "Create KMS key for CloudTrail encryption"
  type        = bool
  default     = true
}

variable "enable_cloudwatch_logs" {
  description = "Enable CloudWatch Logs for CloudTrail"
  type        = bool
  default     = true
}

variable "cloudwatch_retention_days" {
  description = "Retention period for CloudWatch logs (days)"
  type        = number
  default     = 365
}

variable "create_cloudtrail" {
  description = "Create CloudTrail"
  type        = bool
  default     = true
}

variable "cloudtrail_name" {
  description = "Name of the CloudTrail"
  type        = string
  default     = "management-trail"
}

variable "enable_data_events" {
  description = "Enable data events logging (S3 object-level)"
  type        = bool
  default     = false
}

variable "create_sns_topic" {
  description = "Create SNS topic for CloudTrail notifications"
  type        = bool
  default     = true
}

variable "enable_lifecycle_policy" {
  description = "Enable S3 lifecycle policy for cost optimization"
  type        = bool
  default     = true
}

variable "ia_transition_days" {
  description = "Days before transitioning logs to Standard-IA"
  type        = number
  default     = 90
}

variable "glacier_transition_days" {
  description = "Days before transitioning logs to Glacier"
  type        = number
  default     = 180
}

variable "expiration_days" {
  description = "Days before expiring logs (7 years default for compliance)"
  type        = number
  default     = 2555
}
