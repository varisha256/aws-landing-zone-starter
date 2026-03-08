# AWS Landing Zone Starter

[![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.5.0-623CE4?logo=terraform)](https://www.terraform.io)
[![AWS Provider](https://img.shields.io/badge/AWS%20Provider-%3E%3D5.0.0-232F3E?logo=aws)](https://registry.terraform.io/providers/hashicorp/aws)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

> **Enterprise-ready AWS Landing Zone built with Terraform** - Deploy a secure, multi-account AWS environment with security controls, centralized logging, and governance in minutes.

## 🎯 What This Solves

Setting up an AWS organization from scratch is complex and time-consuming. This project provides:

- ✅ **Multi-account structure** following AWS best practices
- ✅ **Security controls** (SCPs, GuardDuty, Security Hub, Config)
- ✅ **Centralized logging** with CloudTrail and S3
- ✅ **Network baseline** with VPCs in each account
- ✅ **Compliance ready** with CIS Benchmarks and lifecycle policies

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         AWS Organization                                     │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                    Security OU                                       │    │
│  │  ┌─────────────────┐  ┌─────────────────┐                          │    │
│  │  │  Security Acct  │  │  Log Archive    │                          │    │
│  │  │  - GuardDuty    │  │  - CloudTrail   │                          │    │
│  │  │  - SecHub       │  │  - S3 Buckets   │                          │    │
│  │  │  - Config       │  │  - KMS          │                          │    │
│  │  └─────────────────┘  └─────────────────┘                          │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                 Infrastructure OU                                    │    │
│  │  ┌─────────────────┐                                                │    │
│  │  │  Infrastructure │  (Shared services, tooling)                   │    │
│  │  └─────────────────┘                                                │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                    Workloads OU                                      │    │
│  │  ┌─────────────────┐  ┌─────────────────┐                          │    │
│  │  │  Production     │  │  Non-Production │                          │    │
│  │  │  - EKS/ECS      │  │  - Dev/Test     │                          │    │
│  │  │  - RDS          │  │  - Staging      │                          │    │
│  │  └─────────────────┘  └─────────────────┘                          │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────────┘

Security Controls (Applied via SCPs):
├── Deny leaving organization
├── Require MFA (optional)
├── Deny unsupported regions
└── Require CloudTrail enabled

Logging Flow:
├── CloudTrail → S3 (encrypted with KMS)
├── CloudTrail → CloudWatch Logs
├── VPC Flow Logs → CloudWatch
└── SNS Notifications for alerts
```

## 📋 Prerequisites

- **AWS Account** with Management/Root account access
- **Terraform** >= 1.5.0
- **AWS CLI** configured with appropriate credentials
- **Unique email addresses** for each AWS account to be created

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/varisha256/aws-landing-zone-starter.git
cd aws-landing-zone-starter/terraform
```

### 2. Initialize Terraform

```bash
terraform init
```

### 3. Create terraform.tfvars

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your configuration:

```hcl
region = "us-east-1"

# Account Emails (REQUIRED - must be unique)
security_account_email      = "aws-security+yourdomain@example.com"
log_archive_account_email   = "aws-logs+yourdomain@example.com"
production_account_email    = "aws-prod+yourdomain@example.com"
non_production_account_email = "aws-dev+yourdomain@example.com"

# Enable security controls
enable_scp_deny_leave_org = true
enable_guardduty          = true
enable_security_hub       = true
```

### 4. Plan and Apply

```bash
terraform plan -out=tfplan
terraform apply tfplan
```

## 📦 Module Structure

```
terraform/
├── main.tf                 # Root module configuration
├── variables.tf            # Input variables
├── outputs.tf              # Output values
├── modules/
│   ├── organizations/      # AWS Organizations & accounts
│   ├── networking/         # VPC, subnets, routing
│   ├── security/           # SCPs, GuardDuty, Security Hub, Config
│   └── logging/            # CloudTrail, S3, KMS, CloudWatch
└── examples/
    ├── basic/              # Minimal security-focused setup
    └── production/         # Full enterprise deployment
```

## ⚙️ Configuration Reference

### Organization & Accounts

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `create_organization` | bool | `false` | Create new AWS Organization |
| `create_security_account` | bool | `true` | Create dedicated Security account |
| `create_log_archive_account` | bool | `true` | Create Log Archive account |
| `create_production_account` | bool | `true` | Create Production workload account |
| `create_non_production_account` | bool | `true` | Create Dev/Test account |

### Security Controls

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `enable_scp_deny_leave_org` | bool | `true` | Prevent accounts from leaving org |
| `enable_scp_require_mfa` | bool | `false` | Require MFA for IAM users |
| `enable_scp_deny_regions` | bool | `false` | Deny access to specific regions |
| `enable_guardduty` | bool | `true` | Enable GuardDuty threat detection |
| `enable_security_hub` | bool | `true` | Enable Security Hub |
| `enable_config` | bool | `true` | Enable AWS Config |

### Logging

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `create_cloudtrail` | bool | `true` | Create multi-region CloudTrail |
| `enable_cloudwatch_logs` | bool | `true` | Send logs to CloudWatch |
| `create_kms_key` | bool | `true` | Create KMS key for encryption |
| `enable_data_events` | bool | `false` | Log S3 object-level events |
| `enable_lifecycle_policy` | bool | `true` | Auto-tier logs to save costs |

## 💰 Cost Estimate

| Component | Monthly Cost (USD) | Notes |
|-----------|-------------------|-------|
| **NAT Gateway** | ~$32.40 each | Per AZ, per account |
| **GuardDuty** | ~$4.00 | Per account, varies with usage |
| **Security Hub** | Free | No additional charge |
| **AWS Config** | ~$2.00 | Per configuration item |
| **CloudTrail** | Free | First trail is free |
| **S3 Storage** | ~$5-10 | Depends on log volume |
| **CloudWatch Logs** | ~$5-15 | Depends on ingestion |
| **KMS Key** | $1.00 | Per key per month |

**Estimated Monthly Total: $50-100** for a basic 5-account setup

### Cost Optimization Tips

1. Disable NAT Gateway in non-critical accounts
2. Use S3 lifecycle policies (enabled by default)
3. Adjust CloudWatch retention periods
4. Use AWS Budgets to monitor spending

## 🔒 Security Features

### Service Control Policies (SCPs)

- **DenyLeaveOrganization**: Prevents member accounts from leaving
- **RequireMFA**: Enforces MFA for all IAM operations (optional)
- **DenyRegions**: Blocks access to non-compliant regions
- **RequireCloudTrail**: Prevents disabling of CloudTrail

### Enabled Security Services

- **GuardDuty**: Threat detection across all accounts
- **Security Hub**: Centralized security posture management
- **AWS Config**: Configuration compliance monitoring
- **CIS Benchmark**: Automated compliance checks

### Data Protection

- All logs encrypted with KMS
- S3 buckets block public access
- VPC Flow Logs enabled
- CloudTrail log file validation

## 📝 Examples

### Basic Setup (Security Controls Only)

```bash
cd examples/basic
terraform init
terraform apply
```

### Full Enterprise Deployment

```bash
cd examples/production
terraform init
terraform apply
```

## 🔧 Usage Patterns

### Deploy to Existing Organization

```hcl
create_organization      = false
existing_organization_id = "o-xxxxxxxxxx"
```

### Add Custom SCPs

```hcl
# In your terraform.tfvars
enable_scp_deny_regions = true
denied_regions          = ["af-south-1", "ap-northeast-3"]
```

### Enable Data Events Logging

```hcl
enable_data_events = true  # S3 object-level CloudTrail
```

### Custom Log Retention

```hcl
cloudwatch_retention_days = 90   # Reduce from 365
expiration_days          = 1825  # 5 years instead of 7
```

## 📤 Outputs

| Output | Description |
|--------|-------------|
| `organization_id` | AWS Organization ID |
| `account_ids` | Map of all account IDs |
| `security_ou_id` | Security OU ID |
| `security_vpc_id` | Security account VPC ID |
| `production_vpc_id` | Production account VPC ID |
| `cloudtrail_bucket_arn` | CloudTrail S3 bucket ARN |
| `guardduty_detector_id` | GuardDuty detector ID |
| `securityhub_account_id` | Security Hub account ID |

## 🛠️ Troubleshooting

### Account Creation Fails

**Error**: "Email already associated with an AWS account"

**Solution**: Each AWS account requires a unique email address. Use email aliases:
```
aws-security+prod@yourdomain.com
aws-logs+prod@yourdomain.com
```

### SCP Not Taking Effect

SCPs can take up to 24 hours to propagate. Wait and retry.

### GuardDuty Already Enabled

If GuardDuty is already enabled in an account, disable the module's GuardDuty:
```hcl
enable_guardduty = false
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👤 Author

**Varisha Karim P MD**
- LinkedIn: [varisha-karim-cloud-devops](https://linkedin.com/in/varisha-karim-cloud-devops)
- Certifications: AWS SAA, GCP ACE, Terraform Associate, KCSA

## 🙏 Acknowledgments

- AWS Well-Architected Framework
- AWS Control Tower documentation
- Terraform AWS Provider community

---

<div align="center">

**Found this useful?** ⭐ Star this repository!

</div>
