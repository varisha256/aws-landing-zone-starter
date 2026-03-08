output "cloudtrail_bucket_id" {
  description = "CloudTrail S3 Bucket ID"
  value       = aws_s3_bucket.cloudtrail.id
}

output "cloudtrail_bucket_arn" {
  description = "CloudTrail S3 Bucket ARN"
  value       = aws_s3_bucket.cloudtrail.arn
}

output "logs_bucket_id" {
  description = "Central Logs S3 Bucket ID"
  value       = aws_s3_bucket.logs.id
}

output "logs_bucket_arn" {
  description = "Central Logs S3 Bucket ARN"
  value       = aws_s3_bucket.logs.arn
}

output "kms_key_id" {
  description = "KMS Key ID for CloudTrail"
  value       = try(aws_kms_key.cloudtrail[0].key_id, null)
}

output "kms_key_arn" {
  description = "KMS Key ARN for CloudTrail"
  value       = try(aws_kms_key.cloudtrail[0].arn, null)
}

output "cloudwatch_log_group_arn" {
  description = "CloudWatch Log Group ARN for CloudTrail"
  value       = try(aws_cloudwatch_log_group.cloudtrail[0].arn, null)
}

output "cloudtrail_id" {
  description = "CloudTrail ID"
  value       = try(aws_cloudtrail.main[0].id, null)
}

output "cloudtrail_arn" {
  description = "CloudTrail ARN"
  value       = try(aws_cloudtrail.main[0].arn, null)
}

output "sns_topic_arn" {
  description = "SNS Topic ARN for CloudTrail notifications"
  value       = try(aws_sns_topic.cloudtrail[0].arn, null)
}

output "sns_topic_name" {
  description = "SNS Topic Name"
  value       = try(aws_sns_topic.cloudtrail[0].name, null)
}
