variable "project" {
  description = "The project name for tagging resources."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string
}

variable "tags" {
  description = "Common tags to apply to resources."
  type        = map(string)
}

variable "ami_id" {
  description = "The ID of the AMI to use in the launch template."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID from networking module"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for the load balancer"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for the ASG instances"
  type        = list(string)
}

variable "instance_type" {
  description = "EC2 instance type for ASG instances."
  type        = string
  default     = "t2.micro"
}

variable "minimum_capacity" {
  description = "Minimum number of instances in the ASG."
  type        = number
  default     = 1
}

variable "maximum_capacity" {
  description = "Maximum number of instances in the ASG."
  type        = number
  default     = 3
}

variable "desired_capacity" {
  description = "Desired number of instances in the ASG."
  type        = number
  default     = 2
}
