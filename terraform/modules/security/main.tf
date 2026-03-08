# Security Module - SCPs, GuardDuty, Security Hub, Config

# Service Control Policies
resource "aws_organizations_policy" "deny_leave_org" {
  count = var.create_scp_deny_leave_org ? 1 : 0
  name  = "DenyLeaveOrganization"
  description = "Prevents accounts from leaving the organization"
  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Deny"
        Action = [
          "organizations:LeaveOrganization",
          "organizations:RemoveAccountFromOrganization"
        ]
        Resource = "*"
      }
    ]
  })

  tags = var.tags
}

resource "aws_organizations_policy" "require_mfa" {
  count = var.create_scp_require_mfa ? 1 : 0
  name  = "RequireMFA"
  description = "Requires MFA for all IAM users"
  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Deny"
        Action = "*"
        Resource = "*"
        Condition = {
          BoolIfExists = {
            "aws:MultiFactorAuthExists" = "false"
          }
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_organizations_policy" "deny_regions" {
  count = var.create_scp_deny_regions ? 1 : 0
  name  = "DenyUnsupportedRegions"
  description = "Denies access to unsupported regions"
  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Deny"
        Action = "*"
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:RequestedRegion" = var.denied_regions
          }
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_organizations_policy" "enable_cloudtrail" {
  count = var.create_scp_enable_cloudtrail ? 1 : 0
  name  = "RequireCloudTrail"
  description = "Requires CloudTrail to be enabled"
  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Deny"
        Action = [
          "cloudtrail:StopLogging",
          "cloudtrail:DeleteTrail"
        ]
        Resource = "arn:aws:cloudtrail:*:*:trail/*"
      }
    ]
  })

  tags = var.tags
}

# Attach SCPs to OUs
resource "aws_organizations_policy_attachment" "deny_leave_org" {
  count     = var.create_scp_deny_leave_org ? 1 : 0
  policy_id = aws_organizations_policy.deny_leave_org[0].id
  target_id = var.target_ou_id
}

resource "aws_organizations_policy_attachment" "require_mfa" {
  count     = var.create_scp_require_mfa ? 1 : 0
  policy_id = aws_organizations_policy.require_mfa[0].id
  target_id = var.target_ou_id
}

resource "aws_organizations_policy_attachment" "deny_regions" {
  count     = var.create_scp_deny_regions ? 1 : 0
  policy_id = aws_organizations_policy.deny_regions[0].id
  target_id = var.target_ou_id
}

resource "aws_organizations_policy_attachment" "enable_cloudtrail" {
  count     = var.create_scp_enable_cloudtrail ? 1 : 0
  policy_id = aws_organizations_policy.enable_cloudtrail[0].id
  target_id = var.target_ou_id
}

# GuardDuty - Organization Level
resource "aws_guardduty_detector" "main" {
  count    = var.enable_guardduty ? 1 : 0
  enable   = true
  finding_publishing_frequency = var.guardduty_finding_frequency

  datasources {
    s3_logs {
      enable = true
    }
    kubernetes {
      audit_logs {
        enable = true
      }
    }
  }

  tags = var.tags
}

resource "aws_guardduty_organization_admin_account" "main" {
  count      = var.enable_guardduty && var.guardduty_admin_account_id != null ? 1 : 0
  admin_account_id = var.guardduty_admin_account_id

  depends_on = [aws_guardduty_detector.main]
}

# Security Hub - Organization Level
resource "aws_securityhub_account" "main" {
  count = var.enable_security_hub ? 1 : 0
}

resource "aws_securityhub_organization_admin_account" "main" {
  count      = var.enable_security_hub && var.security_hub_admin_account_id != null ? 1 : 0
  admin_account_id = var.security_hub_admin_account_id

  depends_on = [aws_securityhub_account.main]
}

resource "aws_securityhub_standards_subscription" "cis" {
  count       = var.enable_security_hub && var.enable_cis_standards ? 1 : 0
  standards_arn = "arn:aws:securityhub:::ruleset/cis-aws-foundations-benchmark/v/1.4.0"

  depends_on = [aws_securityhub_account.main]
}

resource "aws_securityhub_standards_subscription" "foundational" {
  count       = var.enable_security_hub && var.enable_foundational_standards ? 1 : 0
  standards_arn = "arn:aws:securityhub:${var.region}::standards/aws-foundational-security-best-practices/v/1.0.0"

  depends_on = [aws_securityhub_account.main]
}

# AWS Config - Organization Level
resource "aws_config_configuration_recorder" "main" {
  count = var.enable_config ? 1 : 0
  name  = var.config_recorder_name
  role_arn = aws_iam_role.config[0].arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }
}

resource "aws_config_delivery_channel" "main" {
  count  = var.enable_config ? 1 : 0
  name   = var.config_delivery_channel_name
  s3_bucket_name = aws_s3_bucket.config[0].id
  sns_topic_arn  = var.config_sns_topic_arn

  depends_on = [aws_config_configuration_recorder.main]
}

resource "aws_config_configuration_recorder_status" "main" {
  count      = var.enable_config ? 1 : 0
  name       = aws_config_configuration_recorder.main[0].name
  is_enabled = true

  depends_on = [aws_config_delivery_channel.main]
}

resource "aws_s3_bucket" "config" {
  count  = var.enable_config && var.create_config_bucket ? 1 : 0
  bucket = var.config_bucket_name != null ? var.config_bucket_name : "${var.environment}-aws-config-${data.aws_caller_identity.current.account_id}"

  tags = merge(var.tags, {
    Name = "${var.environment}-aws-config-bucket"
  })
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket_server_side_encryption_configuration" "config" {
  count  = var.enable_config && var.create_config_bucket ? 1 : 0
  bucket = aws_s3_bucket.config[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "config" {
  count  = var.enable_config && var.create_config_bucket ? 1 : 0
  bucket = aws_s3_bucket.config[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_iam_role" "config" {
  count = var.enable_config ? 1 : 0
  name  = "${var.environment}-aws-config-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "config" {
  count      = var.enable_config ? 1 : 0
  role       = aws_iam_role.config[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}
