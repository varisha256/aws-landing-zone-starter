variable "create_organization" {
  description = "Whether to create a new AWS Organization"
  type        = bool
  default     = false
}

variable "organization_id" {
  description = "Existing organization ID (if not creating new)"
  type        = string
  default     = null
}

variable "create_security_ou" {
  description = "Create Security organizational unit"
  type        = bool
  default     = true
}

variable "create_infrastructure_ou" {
  description = "Create Infrastructure organizational unit"
  type        = bool
  default     = true
}

variable "create_workloads_ou" {
  description = "Create Workloads organizational unit"
  type        = bool
  default     = true
}

variable "create_shared_services_ou" {
  description = "Create Shared Services organizational unit"
  type        = bool
  default     = true
}

variable "security_ou_name" {
  description = "Name for Security OU"
  type        = string
  default     = "Security"
}

variable "infrastructure_ou_name" {
  description = "Name for Infrastructure OU"
  type        = string
  default     = "Infrastructure"
}

variable "workloads_ou_name" {
  description = "Name for Workloads OU"
  type        = string
  default     = "Workloads"
}

variable "shared_services_ou_name" {
  description = "Name for Shared Services OU"
  type        = string
  default     = "SharedServices"
}

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
  default     = true
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

variable "security_account_name" {
  description = "Name for Security account"
  type        = string
  default     = "Security"
}

variable "security_account_email" {
  description = "Email for Security account"
  type        = string
  default     = ""
}

variable "log_archive_account_name" {
  description = "Name for Log Archive account"
  type        = string
  default     = "LogArchive"
}

variable "log_archive_account_email" {
  description = "Email for Log Archive account"
  type        = string
  default     = ""
}

variable "infrastructure_account_name" {
  description = "Name for Infrastructure account"
  type        = string
  default     = "Infrastructure"
}

variable "infrastructure_account_email" {
  description = "Email for Infrastructure account"
  type        = string
  default     = ""
}

variable "production_account_name" {
  description = "Name for Production account"
  type        = string
  default     = "Production"
}

variable "production_account_email" {
  description = "Email for Production account"
  type        = string
  default     = ""
}

variable "non_production_account_name" {
  description = "Name for Non-Production account"
  type        = string
  default     = "NonProduction"
}

variable "non_production_account_email" {
  description = "Email for Non-Production account"
  type        = string
  default     = ""
}

variable "admin_role_name" {
  description = "Name for the admin IAM role in created accounts"
  type        = string
  default     = "OrganizationAccountAccessRole"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
