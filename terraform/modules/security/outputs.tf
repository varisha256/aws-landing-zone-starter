output "scp_policy_ids" {
  description = "Map of created SCP policy IDs"
  value = {
    deny_leave_org    = try(aws_organizations_policy.deny_leave_org[0].id, null)
    require_mfa       = try(aws_organizations_policy.require_mfa[0].id, null)
    deny_regions      = try(aws_organizations_policy.deny_regions[0].id, null)
    enable_cloudtrail = try(aws_organizations_policy.enable_cloudtrail[0].id, null)
  }
}

output "guardduty_detector_id" {
  description = "GuardDuty Detector ID"
  value       = try(aws_guardduty_detector.main[0].id, null)
}

output "securityhub_account_id" {
  description = "Security Hub Account ID"
  value       = try(aws_securityhub_account.main[0].id, null)
}

output "config_recorder_name" {
  description = "AWS Config Recorder Name"
  value       = try(aws_config_configuration_recorder.main[0].name, null)
}

output "config_bucket_id" {
  description = "AWS Config S3 Bucket ID"
  value       = try(aws_s3_bucket.config[0].id, null)
}

output "config_bucket_arn" {
  description = "AWS Config S3 Bucket ARN"
  value       = try(aws_s3_bucket.config[0].arn, null)
}
