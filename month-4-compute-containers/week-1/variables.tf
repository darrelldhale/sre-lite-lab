variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "Name of the project for tagging resources"
  type        = string
  default     = "sre-lab"
}

variable "environment" {
  description = "Deployment environment for tagging and resource sizing (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "ami_id" {
  description = "Base AMI ID baked from Month 3 instance"
  type        = string
  default     = "ami-06e35715bc33b8177"
}
