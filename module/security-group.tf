# Security group for EC2 instances from ASG template
resource "aws_security_group" "instance_prod" {
  name        = "${var.cluster_name}-prod"
  description = "Security group for web servers - allows port 8080 inbound from Load Balancer SG"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    Name = "${var.cluster_name}-instance-sg"
  }
}

# Traffic Inbound Rule for Instances in AutoScaling Target Group Only From Load Balancer  

resource "aws_vpc_security_group_ingress_rule" "instance-inbound" {
  security_group_id            = aws_security_group.instance_prod.id
  referenced_security_group_id = aws_security_group.elb.id

  #   cidr_ipv4   = local.all_ips
  ip_protocol = local.tcp_protocol
  from_port   = var.server_port
  to_port     = var.server_port
}

# Traffic Outbound Rule for Instances in AutoScaling Target group

resource "aws_vpc_security_group_egress_rule" "instance-outbound" {
  security_group_id = aws_security_group.instance_prod.id

  cidr_ipv4   = local.all_ips
  ip_protocol = local.any_protocol
  from_port   = local.any_port
  to_port     = local.any_port
}

# Security group for the Application Load Balancer

resource "aws_security_group" "elb" {
  name        = "${var.cluster_name}-elb"
  description = "Security group for load balancer - allows port 80 inbound"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    Name = "${var.cluster_name}-elb-sg"
  }
}

# Traffic Inbound Rule for Load Balancer

resource "aws_vpc_security_group_ingress_rule" "elb-http-inbound" {
  security_group_id = aws_security_group.elb.id

  from_port   = local.http_port
  to_port     = local.http_port
  cidr_ipv4   = local.all_ips
  ip_protocol = local.tcp_protocol

}

resource "aws_vpc_security_group_ingress_rule" "elb-https-inbound" {
  security_group_id = aws_security_group.elb.id

  from_port   = local.https_port
  to_port     = local.https_port
  cidr_ipv4   = local.all_ips
  ip_protocol = local.tcp_protocol

}
# Traffic Outbound Rule for Load Balancer
resource "aws_vpc_security_group_egress_rule" "elb-outbound" {
  security_group_id = aws_security_group.elb.id

  cidr_ipv4   = local.all_ips
  ip_protocol = local.any_protocol
  from_port   = local.any_port
  to_port     = local.any_port
}