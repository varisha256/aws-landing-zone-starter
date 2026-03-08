variable "environment" {
  description = "Environment name"
  type        = string
}

variable "region" {
  description = "AWS Region"
  type        = string
}

variable "target_ou_id" {
  description = "Organizational Unit ID to attach SCPs"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# SCP Variables
variable "create_scp_deny_leave_org" {
  description = "Create SCP to deny leaving organization"
  type        = bool
  default     = true
}

variable "create_scp_require_mfa" {
  description = "Create SCP to require MFA"
  type        = bool
  default     = false
}

variable "create_scp_deny_regions" {
  description = "Create SCP to deny specific regions"
  type        = bool
  default     = false
}

variable "denied_regions" {
  description = "List of regions to deny"
  type        = list(string)
  default     = []
}

variable "create_scp_enable_cloudtrail" {
  description = "Create SCP to require CloudTrail"
  type        = bool
  default     = true
}

# GuardDuty Variables
variable "enable_guardduty" {
  description = "Enable GuardDuty"
  type        = bool
  default     = true
}

variable "guardduty_finding_frequency" {
  description = "GuardDuty finding publishing frequency"
  type        = string
  default     = "FIFTEEN_MINUTES"
  validation {
    condition     = contains(["FIFTEEN_MINUTES", "ONE_HOUR", "SIX_HOURS"], var.guardduty_finding_frequency)
    error_message = "Valid values are FIFTEEN_MINUTES, ONE_HOUR, or SIX_HOURS."
  }
}

variable "guardduty_admin_account_id" {
  description = "GuardDuty delegated admin account ID"
  type        = string
  default     = null
}

# Security Hub Variables
variable "enable_security_hub" {
  description = "Enable Security Hub"
  type        = bool
  default     = true
}

variable "security_hub_admin_account_id" {
  description = "Security Hub delegated admin account ID"
  type        = string
  default     = null
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

# AWS Config Variables
variable "enable_config" {
  description = "Enable AWS Config"
  type        = bool
  default     = true
}

variable "config_recorder_name" {
  description = "Name for Config recorder"
  type        = string
  default     = "default"
}

variable "config_delivery_channel_name" {
  description = "Name for Config delivery channel"
  type        = string
  default     = "default"
}

variable "create_config_bucket" {
  description = "Create S3 bucket for Config"
  type        = bool
  default     = true
}

variable "config_bucket_name" {
  description = "Name of Config S3 bucket"
  type        = string
  default     = null
}

variable "config_sns_topic_arn" {
  description = "SNS topic ARN for Config notifications"
  type        = string
  default     = null
}
