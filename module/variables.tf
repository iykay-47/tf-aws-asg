variable "region" {
  description = "region to deploy this in"
  type        = string
}

variable "cluster_name" {
  description = "Name of project/cluster for auto-scaling"
  type        = string
  default     = "static-auto-scaling"
}

variable "server_port" {
  description = "Port which instance accept traffic from in asg"
  type        = number
  default     = 8080
}

variable "ami_id" {
  description = "AMI for instancce launch"
  type        = string
}

variable "instance_type" {
  description = "Instance type/size"
  type        = string
  default     = "t2.micro"
}

variable "min_size" {
  description = "minimum asg instances available at all times"
  type        = number
  default     = 2
  validation {
    condition     = var.min_size >= 1
    error_message = "min_size must be at least 1."
  }
}

variable "max_size" {
  description = "maximum number of instances available at all times"
  type        = number
  default     = 5
  validation {
    condition     = var.max_size >= 1
    error_message = "max_size must be at least 1."
  }
}

variable "desired_capacity" {
  description = "optimal number of instances"
  type        = number
  default     = 3
  validation {
    condition     = var.desired_capacity >= var.min_size && var.desired_capacity <= var.max_size
    error_message = "desired_capacity must be between min_size and max_size."
  }
}

variable "custom_tags" {
  description = "Custom tags to set on the Instances in the ASG"
  type        = map(string)
  default     = {}
}

variable "enable_schedule" {
  description = "If to enable auto scaling or not"
  type        = bool
  default     = false
}

variable "schedule_scale_out_max" {
  description = "Maximum instances for scaling out"
  type        = number
  default     = 5
}

variable "schedule_scale_out_desired" {
  description = "Desired instance size for scheduled scaling out"
  type        = number
  default     = 5
  validation {
    condition     = var.schedule_scale_out_desired >= var.min_size && var.schedule_scale_out_desired <= var.schedule_scale_out_max
    error_message = "schedule_scale_out_desired must be between min_size and schedule_scale_out_max."
  }
}

variable "schedule_scale_out_cron" {
  description = "Time to scale out instances"
  type        = string
  default     = "30 7 * * *"
}

variable "schedule_scale_in_cron" {
  description = "Time to scale in instances"
  type        = string
  default     = "0 18 * * *"
}

variable "instance_refresh_min_health_percentage" {
  type    = number
  default = 50
  validation {
    condition     = var.instance_refresh_min_health_percentage >= 0 && var.instance_refresh_min_health_percentage <= 100
    error_message = "Must be between 0 and 100."
  }
}