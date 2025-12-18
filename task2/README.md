# AWS Infrastructure with Terraform

This project provisions a basic web application stack on AWS using Terraform.
## Components

| Component | AWS Service | Purpose |
|-----------|-------------|---------|
| Load Balancer | ALB | Distributes traffic to web servers |
| Web Servers | EC2 (x2) | Nginx serving simple web page |
| Database | RDS PostgreSQL | Application database |
| Network | VPC | Isolated network with public/private subnets |

## Prerequisites

- AWS account
- Terraform
- AWS CLI configured

## Quick Start

```bash
# generate ssh key for ec2 instances
aws ec2 create-key-pair --key-name digitall-sap-key --query 'KeyMaterial' --output text > digitall-sap-key.pem
chmod 400 digitall-sap-key.pem
# edit terraform.tfvars with your values

# deploy
terraform init
terraform plan
terraform apply
```

## Outputs

After successful apply:

```bash
terraform output alb_dns_name     # URL to access the app
terraform output web_server_ips   # EC2 public IPs for SSH
terraform output db_endpoint      # RDS endpoint
```

## Fail-over

The setup includes:

- **ALB Health Checks**: Automatically removes unhealthy instances from rotation
- **Multi-AZ EC2**: Web servers in different availability zones
- **Multi-AZ RDS** (optional): Set `db_multi_az = true` for database HA

To test fail-over:
1. Stop one EC2 instance in AWS console
2. ALB will route traffic to remaining instance
3. Start the instance - it rejoins automatically

## Cleanup

```bash
terraform destroy
```
