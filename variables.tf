variable "region" {
  description = "region to deploy this in"
  type        = string
}

variable "cluster_name" {
  description = "Name of project/cluster for auto-scaling"
  type        = string
}

variable "server_port" {
  description = "Port which instance accept traffic from in asg"
  type        = number
}

variable "ami_id" {
  description = "AMI for instancce launch"
  type        = string
}

variable "instance_type" {
  description = "Instance type/size"
  type        = string
}

variable "min_size" {
  description = "minimum asg instances available at all times"
  type        = number
  validation {
    condition     = var.min_size >= 1
    error_message = "min_size must be at least 1."
  }
}

variable "max_size" {
  description = "maximum number of instances available at all times"
  type        = number
}

variable "desired_capacity" {
  description = "optimal number of instances"
  type        = number
  validation {
    condition     = var.desired_capacity >= var.min_size && var.desired_capacity <= var.max_size
    error_message = "desired_capacity must be between min_size and max_size."
  }
}

variable "custom_tags" {
  description = "Custom tags to set on the Instances in the ASG"
  type        = map(string)
}

variable "enable_schedule" {
  description = "If to enable auto scaling or not"
  type        = bool
}

# variable "schedule_scale_out_max" {
#   description = "Maximum instances for scaling out"
#   type        = number
# }

# variable "schedule_scale_out_desired" {
#   description = "Desired instance size for scheduled scaling out"
#   type        = number
# }

# variable "schedule_scale_out_cron" {
#   description = "Time to scale out instances"
#   type        = string
# }

# variable "schedule_scale_in_cron" {
#   description = "Time to scale in instances"
#   type        = string
# }

variable "instance_refresh_min_health_percentage" {
  description = "Minimum Instances healthy in ASG during instance refresh"
  type        = number
}

