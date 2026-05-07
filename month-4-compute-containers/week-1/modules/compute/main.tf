# === Security Group: Application Load Balancer ===
resource "aws_security_group" "alb_sg" {
  name        = "${var.project}-${var.environment}-alb-sg"
  description = "Allow inbound HTTP from internet to ALB"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    "Name" = "${var.project}-${var.environment}-alb-sg"
  })
}

# === Security Group: ASG Instances ===
resource "aws_security_group" "asg_instances_sg" {
  name        = "${var.project}-${var.environment}-asg-instances-sg"
  description = "Allow inbound HTTP from ALB to ASG instances"
  vpc_id      = var.vpc_id

  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    "Name" = "${var.project}-${var.environment}-asg-instances-sg"
  })
}

# === IAM Role: EC2 Instance Role ===
resource "aws_iam_role" "ec2_role" {
  name = "${var.project}-${var.environment}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(var.tags, {
    "Name" = "${var.project}-${var.environment}-ec2-role"
  })
}

# === IAM Role Policy Attachment: EC2 Role to SSM Managed Policy ===
resource "aws_iam_role_policy_attachment" "ec2_ssm" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# === IAM Role Policy Attachment: EC2 Role to CloudWatch Agent Policy ===
resource "aws_iam_role_policy_attachment" "ec2_cloudwatch" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# === IAM Instance Profile: EC2 Instance Profile ===
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "${var.project}-${var.environment}-ec2-instance-profile"
  role = aws_iam_role.ec2_role.name

  tags = merge(var.tags, {
    "Name" = "${var.project}-${var.environment}-ec2-instance-profile"
  })
}

# === Launch Template: ASG Launch Template ===
resource "aws_launch_template" "asg_launch_template" {
  name          = "${var.project}-${var.environment}-asg-launch-template"
  description   = "Launch template for ASG instances"
  image_id      = var.ami_id
  instance_type = var.instance_type

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_instance_profile.name
  }

  network_interfaces {
    security_groups             = [aws_security_group.asg_instances_sg.id]
    associate_public_ip_address = false
  }

  metadata_options {
    http_tokens = "required"
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.tags, {
      "Name" = "${var.project}-${var.environment}-asg-instance"
    })
  }

  tags = merge(var.tags, {
    "Name" = "${var.project}-${var.environment}-asg-launch-template"
  })
}

# === Target Group: ALB Target Group ===
resource "aws_lb_target_group" "alb_target_group" {
  name     = "${var.project}-${var.environment}-alb-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = merge(var.tags, {
    "Name" = "${var.project}-${var.environment}-alb-target-group"
  })
}

# === Application Load Balancer: ALB ===
resource "aws_lb" "app_load_balancer" {
  name               = "${var.project}-${var.environment}-app-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnet_ids

  tags = merge(var.tags, {
    "Name" = "${var.project}-${var.environment}-app-load-balancer"
  })
}

# === ALB Listener: HTTP Listener ===
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.app_load_balancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.arn
  }
}

# === Auto Scaling Group: ASG ===
resource "aws_autoscaling_group" "app_asg" {
  name             = "${var.project}-${var.environment}-app-asg"
  max_size         = var.maximum_capacity
  min_size         = var.minimum_capacity
  desired_capacity = var.desired_capacity

  launch_template {
    id      = aws_launch_template.asg_launch_template.id
    version = "$Latest"
  }
  vpc_zone_identifier       = var.private_subnet_ids
  target_group_arns         = [aws_lb_target_group.alb_target_group.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 300

  tag {
    key                 = "Name"
    value               = "${var.project}-${var.environment}-asg-instance"
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

