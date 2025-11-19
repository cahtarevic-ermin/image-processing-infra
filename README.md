# 🏗️ Image Processing Infrastructure

Terraform infrastructure for automated image processing pipeline on AWS.

## What It Creates

This Terraform configuration automatically provisions:
- ✅ **2 S3 Buckets** - Source (uploads) and destination (processed)
- ✅ **Lambda Function** - Serverless image processor
- ✅ **IAM Roles** - Secure permissions for Lambda
- ✅ **S3 Triggers** - Automatic processing on upload
- ✅ **CloudWatch Logs** - Monitoring and debugging

## Prerequisites

- Terraform >= 1.0
- AWS CLI configured (`aws configure`)
- AWS credentials with admin access
- Lambda deployment package (from `/image-processing-lambda`)

## Quick Start

### 1. Install Terraform

```bash
# Ubuntu/Debian
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt-get update && sudo apt-get install terraform

# Verify
terraform --version
```

### 2. Configure AWS

```bash
aws configure
# Enter: Access Key, Secret Key, Region (us-east-1), Output (json)
```

### 3. Build Lambda Package

```bash
cd ../image-processing-lambda
./deployment/build.sh
cd ../image-processing-infra
```

### 4. Configure Variables

Edit `terraform.tfvars`:

```hcl
aws_region  = "us-east-1"
environment = "dev"

# IMPORTANT: Must be globally unique!
source_bucket_name      = "your-uploads-unique-name-123"
destination_bucket_name = "your-processed-unique-name-123"

# Optional
discord_webhook_url = "https://discord.com/api/webhooks/YOUR_ID/TOKEN"
enable_notifications = true
```

### 5. Deploy

```bash
# Initialize Terraform
terraform init

# Preview changes
terraform plan

# Deploy infrastructure
terraform apply
# Type 'yes' when prompted
```

## File Structure

```
image-processing-infra/
├── main.tf              # Main configuration
├── variables.tf         # Input variables
├── outputs.tf          # Output values
├── terraform.tfvars    # Your values (don't commit!)
├── versions.tf         # Provider versions
├── iam.tf             # IAM roles & policies
├── s3.tf              # S3 buckets & triggers
├── lambda.tf          # Lambda function
├── cloudwatch.tf      # Log groups
└── .gitignore         # Git ignore rules
```

## Configuration Options

| Variable | Description | Required | Default |
|----------|-------------|----------|---------|
| `aws_region` | AWS region | No | `us-east-1` |
| `environment` | Environment name | No | `dev` |
| `source_bucket_name` | Upload bucket | Yes | - |
| `destination_bucket_name` | Processed bucket | Yes | - |
| `lambda_timeout` | Timeout in seconds | No | `60` |
| `lambda_memory_size` | Memory in MB | No | `512` |
| `discord_webhook_url` | Notification URL | No | - |

## Common Commands

```bash
# Initialize (first time only)
terraform init

# Preview changes
terraform plan

# Apply changes
terraform apply

# Show current state
terraform show

# List resources
terraform state list

# Get outputs
terraform output

# Destroy everything
terraform destroy
```

## Testing the Pipeline

```bash
# Get bucket names
terraform output source_bucket_name

# Upload test image
aws s3 cp test-image.jpg s3://$(terraform output -raw source_bucket_name)/

# Check Lambda logs
aws logs tail /aws/lambda/$(terraform output -raw lambda_function_name) --follow

# View processed image
aws s3 ls s3://$(terraform output -raw destination_bucket_name)/processed/
```

## Outputs

After deployment, you'll get:

```bash
source_bucket_name      = "your-uploads-bucket"
destination_bucket_name = "your-processed-bucket"
lambda_function_name    = "image-processing-dev"
lambda_function_arn     = "arn:aws:lambda:..."
cloudwatch_log_group    = "/aws/lambda/image-processing-dev"
```

## Cost Estimate

**Monthly cost (dev environment, ~1000 images):**
- S3 Storage: ~$0.50
- Lambda Executions: ~$0.20
- CloudWatch Logs: ~$0.10
- **Total: < $1/month**

*Production costs scale with usage*

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Bucket name taken | Change to unique name in `terraform.tfvars` |
| Lambda permission error | Run `terraform apply` again |
| No such file: lambda.zip | Build package: `cd ../image-processing-lambda && ./deployment/build.sh` |
| AWS credentials error | Run `aws configure` |

## Updating Lambda Code

```bash
# Rebuild Lambda package
cd ../image-processing-lambda
./deployment/build.sh
cd ../image-processing-infra

# Update Lambda function
terraform apply -target=aws_lambda_function.image_processor
```

## Cleanup

To remove all resources:

```bash
# Empty S3 buckets first (can't delete non-empty buckets)
aws s3 rm s3://$(terraform output -raw source_bucket_name) --recursive
aws s3 rm s3://$(terraform output -raw destination_bucket_name) --recursive

# Destroy infrastructure
terraform destroy
```

## Security Best Practices

✅ S3 buckets are private by default  
✅ IAM roles use least-privilege access  
✅ Bucket versioning enabled  
✅ CloudWatch logging enabled  
✅ Environment variables for secrets

## Related Projects

- [image-processing-lambda](https://github.com/cahtarevic-ermin/image-processing-lambda) - Lambda function code

## Support

**Check logs:**
```bash
aws logs tail /aws/lambda/image-processing-dev --follow
```

**Check Terraform state:**
```bash
terraform show
```

For Lambda code issues, see the `image-processing-lambda` repository.
