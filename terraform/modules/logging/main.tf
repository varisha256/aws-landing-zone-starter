# Logging Module - Centralized CloudTrail and Log Management

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# S3 Bucket for CloudTrail Logs
resource "aws_s3_bucket" "cloudtrail" {
  bucket = var.cloudtrail_bucket_name != null ? var.cloudtrail_bucket_name : "${var.environment}-cloudtrail-logs-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}"

  tags = merge(var.tags, {
    Name        = "${var.environment}-cloudtrail-logs"
    Environment = var.environment
  })
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.cloudtrail[0].arn
    }
  }
}

resource "aws_s3_bucket_public_access_block" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSCloudTrailAclCheck"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.cloudtrail.arn
        Condition = {
          StringEquals = {
            "aws:SourceArn" = "arn:aws:cloudtrail:*:${data.aws_caller_identity.current.account_id}:trail/*"
          }
        }
      },
      {
        Sid    = "AWSCloudTrailWrite"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.cloudtrail.arn}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl"         = "bucket-owner-full-control"
            "aws:SourceArn"        = "arn:aws:cloudtrail:*:${data.aws_caller_identity.current.account_id}:trail/*"
          }
        }
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.cloudtrail]
}

# S3 Bucket for General Logs
resource "aws_s3_bucket" "logs" {
  bucket = var.logs_bucket_name != null ? var.logs_bucket_name : "${var.environment}-central-logs-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}"

  tags = merge(var.tags, {
    Name        = "${var.environment}-central-logs"
    Environment = var.environment
  })
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "logs" {
  bucket = aws_s3_bucket.logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# KMS Key for CloudTrail
resource "aws_kms_key" "cloudtrail" {
  count                   = var.create_kms_key ? 1 : 0
  description             = "KMS key for CloudTrail log encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  tags = merge(var.tags, {
    Name = "${var.environment}-cloudtrail-kms"
  })
}

resource "aws_kms_alias" "cloudtrail" {
  count         = var.create_kms_key ? 1 : 0
  name          = "alias/${var.environment}-cloudtrail"
  target_key_id = aws_kms_key.cloudtrail[0].key_id
}

# CloudWatch Log Group for CloudTrail
resource "aws_cloudwatch_log_group" "cloudtrail" {
  count             = var.enable_cloudwatch_logs ? 1 : 0
  name              = "/aws/cloudtrail/${var.environment}-management-events"
  retention_in_days = var.cloudwatch_retention_days

  tags = var.tags
}

resource "aws_cloudwatch_log_group" "cloudtrail_data" {
  count             = var.enable_cloudwatch_logs && var.enable_data_events ? 1 : 0
  name              = "/aws/cloudtrail/${var.environment}-data-events"
  retention_in_days = var.cloudwatch_retention_days

  tags = var.tags
}

# IAM Role for CloudTrail to CloudWatch Logs
resource "aws_iam_role" "cloudtrail_logs" {
  count = var.enable_cloudwatch_logs ? 1 : 0
  name  = "${var.environment}-cloudtrail-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "cloudtrail_logs" {
  count = var.enable_cloudwatch_logs ? 1 : 0
  name  = "${var.environment}-cloudtrail-logs-policy"
  role  = aws_iam_role.cloudtrail_logs[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "${aws_cloudwatch_log_group.cloudtrail[0].arn}:*"
      }
    ]
  })
}

# CloudTrail - Management Events
resource "aws_cloudtrail" "main" {
  count                         = var.create_cloudtrail ? 1 : 0
  name                          = var.cloudtrail_name
  s3_bucket_name                = aws_s3_bucket.cloudtrail.id
  s3_key_prefix                 = "management-events"
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true
  kms_key_id                    = var.create_kms_key ? aws_kms_key.cloudtrail[0].arn : null
  cloud_watch_logs_group_arn    = var.enable_cloudwatch_logs ? "${aws_cloudwatch_log_group.cloudtrail[0].arn}:*" : null
  cloud_watch_logs_role_arn     = var.enable_cloudwatch_logs ? aws_iam_role.cloudtrail_logs[0].arn : null

  event_selector {
    read_write_type           = "All"
    include_management_events = true
  }

  tags = merge(var.tags, {
    Name = var.cloudtrail_name
  })

  depends_on = [aws_s3_bucket_policy.cloudtrail]
}

# CloudTrail - Data Events (S3)
resource "aws_cloudtrail" "data_events" {
  count                      = var.create_cloudtrail && var.enable_data_events ? 1 : 0
  name                       = "${var.cloudtrail_name}-data"
  s3_bucket_name             = aws_s3_bucket.cloudtrail.id
  s3_key_prefix              = "data-events"
  is_multi_region_trail      = true
  enable_log_file_validation = true
  kms_key_id                 = var.create_kms_key ? aws_kms_key.cloudtrail[0].arn : null

  event_selector {
    read_write_type = "All"
    include_management_events = false

    data_resource {
      type   = "AWS::S3::Object"
      values = ["arn:aws:s3"]
    }
  }

  tags = merge(var.tags, {
    Name = "${var.cloudtrail_name}-data"
  })

  depends_on = [aws_s3_bucket_policy.cloudtrail]
}

# SNS Topic for CloudTrail notifications
resource "aws_sns_topic" "cloudtrail" {
  count = var.create_sns_topic ? 1 : 0
  name  = "${var.environment}-cloudtrail-notifications"

  tags = var.tags
}

# S3 Bucket Lifecycle Policy
resource "aws_s3_bucket_lifecycle_configuration" "cloudtrail" {
  count  = var.enable_lifecycle_policy ? 1 : 0
  bucket = aws_s3_bucket.cloudtrail.id

  rule {
    id     = "transition-to-ia"
    status = "Enabled"

    transition {
      days          = var.ia_transition_days
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = var.glacier_transition_days
      storage_class = "GLACIER"
    }

    expiration {
      days = var.expiration_days
    }
  }
}
