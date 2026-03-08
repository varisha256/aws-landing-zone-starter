variable "environment" {
  description = "Environment name"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# Bucket Configuration
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

# KMS Configuration
variable "create_kms_key" {
  description = "Create KMS key for CloudTrail encryption"
  type        = bool
  default     = true
}

# CloudWatch Logs Configuration
variable "enable_cloudwatch_logs" {
  description = "Enable CloudWatch Logs for CloudTrail"
  type        = bool
  default     = true
}

variable "cloudwatch_retention_days" {
  description = "Retention period for CloudWatch logs"
  type        = number
  default     = 365
}

variable "enable_data_events" {
  description = "Enable data events logging (S3)"
  type        = bool
  default     = false
}

# CloudTrail Configuration
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

# SNS Configuration
variable "create_sns_topic" {
  description = "Create SNS topic for notifications"
  type        = bool
  default     = true
}

# Lifecycle Policy
variable "enable_lifecycle_policy" {
  description = "Enable S3 lifecycle policy"
  type        = bool
  default     = true
}

variable "ia_transition_days" {
  description = "Days before transitioning to Standard-IA"
  type        = number
  default     = 90
}

variable "glacier_transition_days" {
  description = "Days before transitioning to Glacier"
  type        = number
  default     = 180
}

variable "expiration_days" {
  description = "Days before expiring logs"
  type        = number
  default     = 2555 # 7 years
}
