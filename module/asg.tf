resource "aws_launch_template" "ubuntu-static" {
  name                   = "${var.cluster_name}-LT"
  image_id               = var.ami_id # Default Ubuntu 24.04 LTS
  instance_type          = var.instance_type
  user_data              = filebase64("${path.module}/user-data.sh")
  vpc_security_group_ids = [aws_security_group.instance_prod.id]
  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Created_With = "ASG"
      Managed_With = "Terraform"
    }
  }
}

resource "aws_autoscaling_group" "web_server_asg" {
  launch_template {
    id      = aws_launch_template.ubuntu-static.id
    version = aws_launch_template.ubuntu-static.latest_version
  }

  name = "${var.cluster_name}-asg"

  vpc_zone_identifier = data.aws_subnets.default.ids

  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity

  health_check_type = "ELB"

  target_group_arns = [aws_lb_target_group.asg_lg_tg.arn]

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = var.instance_refresh_min_health_percentage
      auto_rollback          = true
    }
  }

  tag {
    key                 = "Name"
    value               = "${var.cluster_name}-asg"
    propagate_at_launch = true
  }

  dynamic "tag" {
    # for_each = var.custom_tags
    for_each = {
      for key, value in var.custom_tags :
      key => upper(value)
      if key != "Name"
    }
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

# Scale out at 7:30am every morning
resource "aws_autoscaling_schedule" "scale-out-hr" {

  count = var.enable_schedule ? 1 : 0

  scheduled_action_name  = "${var.cluster_name}-scale-out-during-business-hours"
  min_size               = var.min_size
  max_size               = var.schedule_scale_out_max
  desired_capacity       = var.schedule_scale_out_desired
  recurrence             = var.schedule_scale_out_cron
  autoscaling_group_name = aws_autoscaling_group.web_server_asg.name #module.webserver-cluster.asg-name

}

# Scale in at 6:00pm every evening
resource "aws_autoscaling_schedule" "scale-in-hrs" {

  count                  = var.enable_schedule ? 1 : 0
  scheduled_action_name  = "${var.cluster_name}-scale-in-at-night"
  min_size               = var.min_size
  max_size               = var.max_size
  desired_capacity       = var.desired_capacity
  recurrence             = var.schedule_scale_in_cron
  autoscaling_group_name = aws_autoscaling_group.web_server_asg.name #module.webserver-cluster.asg-name
}

resource "aws_autoscaling_policy" "load_scaling" {
  name                   = "${var.cluster_name}-asg-policy"
  autoscaling_group_name = aws_autoscaling_group.web_server_asg.name

  policy_type = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 50.0
  }
}