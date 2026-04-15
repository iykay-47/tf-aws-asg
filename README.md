# AWS Auto Scaling Group with Application Load Balancer

Terraform project that provisions a production-ready, CPU-driven Auto Scaling Group behind an Application Load Balancer on AWS. Infrastructure is packaged as a reusable module and configured entirely through variables.

---

## Architecture

```
Internet
   │
   ▼
Application Load Balancer  (port 80 → HTTP)
   │  Security Group: allows 0.0.0.0/0 on port 80
   │
   ▼
Auto Scaling Group  (min 2 · desired 3 · max 5)
   │  EC2 instances: Ubuntu 24.04, Apache on port 8080
   │  Security Group: allows inbound only from ALB SG
   │
   ▼
Target Group  (health check: GET / → 200)
```

Traffic flows from the internet to the ALB on port 80, which forwards to EC2 instances running Apache on port 8080. Instances are only reachable through the load balancer — direct public access is blocked at the security group level.

**Scaling policy:** `TargetTrackingScaling` targeting 50% average CPU utilisation. Optional time-based schedules allow capacity to scale out at a set morning cron and scale back in at a set evening cron.

---

## Project Structure

```
tf-autoscaling-pjt/
├── main.tf              # Root entry point — calls the asg module
├── variables.tf         # Root variable declarations
├── output.tf            # Outputs (ALB DNS name)
├── terraform.tfvars     # Variable values (not committed in production)
└── module/
    ├── main.tf          # Terraform + provider config
    ├── asg.tf           # Launch template, ASG, scaling policy, schedules
    ├── elb.tf           # ALB, target group, listener
    ├── security-group.tf
    ├── data.tf          # Default VPC + subnet data sources
    ├── locals.tf        # Port and protocol constants
    ├── variables.tf     # Module variable declarations
    ├── output.tf        # Module outputs
    └── user-data.sh     # Apache bootstrap script
```

---

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.0
- AWS CLI configured with credentials (`aws configure`)
- An AWS account with permissions to manage EC2, ALB, ASG, and VPC resources

---

## Usage

### 1. Clone the repo

```bash
git clone https://github.com/iykay-47/tf-aws-asg.git
cd tf-autoscaling-pjt
```

### 2. Set variable values

Edit `terraform.tfvars` with your desired configuration:

```hcl
region           = "us-east-2"
cluster_name     = "static-auto-scaling"
ami_id           = "ami-07062e2a343acc423"  # Ubuntu 24.04 LTS (us-east-2)
instance_type    = "t2.micro"
min_size         = 2
max_size         = 5
desired_capacity = 3
```

> **Note:** `ami_id` is region-specific. Update this value if deploying to a different region.

### 3. Initialise and apply

```bash
terraform init
terraform plan
terraform apply
```

The ALB DNS name is printed as an output after a successful apply:

```
Outputs:
  elb_dns = "static-auto-scaling-lb-<id>.us-east-2.elb.amazonaws.com"
```

### 4. Destroy

```bash
terraform destroy
```

---

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `region` | AWS region to deploy into | `string` | `us-east-2` | no |
| `cluster_name` | Name prefix for all resources | `string` | `static-auto-scaling` | no |
| `ami_id` | AMI ID for EC2 instances | `string` | — | **yes** |
| `instance_type` | EC2 instance size | `string` | `t2.micro` | no |
| `min_size` | Minimum instances in the ASG | `number` | `2` | no |
| `max_size` | Maximum instances in the ASG | `number` | `5` | no |
| `desired_capacity` | Target instance count | `number` | `3` | no |
| `custom_tags` | Tags propagated to all ASG instances | `map(string)` | `{}` | no |
| `enable_schedule` | Enable time-based scaling schedules | `bool` | `false` | no |
| `schedule_scale_out_cron` | Cron expression for morning scale-out | `string` | `30 7 * * *` | no |
| `schedule_scale_in_cron` | Cron expression for evening scale-in | `string` | `0 18 * * *` | no |
| `instance_refresh_min_health_percentage` | Min healthy % during rolling refresh | `number` | `50` | no |

---

## Optional: Time-Based Scaling

To enable business-hours scaling, set `enable_schedule = true` in `terraform.tfvars` and uncomment the schedule variables:

```hcl
enable_schedule            = true
schedule_scale_out_max     = 5
schedule_scale_out_desired = 5
schedule_scale_out_cron    = "30 7 * * *"   # Scale out at 07:30 UTC
schedule_scale_in_cron     = "0 18 * * *"   # Scale in at 18:00 UTC
```

Cron expressions follow AWS Auto Scaling format (UTC).

---

## Instance Refresh

Any change to the launch template (e.g. new AMI, updated user data) triggers a rolling instance refresh automatically. The refresh replaces instances while keeping at least `instance_refresh_min_health_percentage` healthy, with automatic rollback on failure.

---

## Outputs

| Name | Description |
|------|-------------|
| `elb_dns` | DNS name of the Application Load Balancer |

---

## Roadmap

- [ ] Add S3 + DynamoDB remote state backend
- [ ] HTTPS listener with ACM certificate
- [ ] Move from default VPC to dedicated VPC with private subnets
- [ ] CloudWatch alarms and SNS notifications

---

## Tags Applied to Instances

Custom tags passed via `custom_tags` are propagated to all instances at launch. Values are automatically uppercased. The `Name` tag is managed separately by the ASG and cannot be overridden via `custom_tags`.

Example from `terraform.tfvars`:

```hcl
custom_tags = {
  Environment = "Production"
  App         = "Static"
  Cost_Center = "Ecom"
  Owners      = "Emage-Tech"
}
```

---

## License

MIT