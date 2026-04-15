region           = "us-east-2"
cluster_name     = "static-auto-scaling"
server_port      = 8080
ami_id           = "ami-07062e2a343acc423" # Ubuntu 24.04 LTS
instance_type    = "t2.micro"
min_size         = 2
max_size         = 5
desired_capacity = 3

custom_tags = {
  Created_By  = "Terraform"
  Managed_By  = "Terraform"
  Environment = "Production"
  App         = "Static"
  Cost_Center = "Ecom"
  Owners      = "Emage-Tech"
}

enable_schedule = false



instance_refresh_min_health_percentage = 50