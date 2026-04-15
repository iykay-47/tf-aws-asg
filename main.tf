terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  required_version = ">= 1.9"
}

provider "aws" {
  region = var.region
}

module "asg" {
  source           = "./module/"
  region           = var.region
  cluster_name     = var.cluster_name
  server_port      = var.server_port
  ami_id           = var.ami_id
  instance_type    = var.instance_type
  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity

  custom_tags = var.custom_tags

  enable_schedule = var.enable_schedule

  # # Edit below whn enable_schedule is set to true
# schedule_scale_out_max = 5
# schedule_scale_out_desired = 5
# schedule_scale_out_cron = "30 7 * * *"
# schedule_scale_in_cron = "0 18 * * *"

  instance_refresh_min_health_percentage = var.instance_refresh_min_health_percentage

}
