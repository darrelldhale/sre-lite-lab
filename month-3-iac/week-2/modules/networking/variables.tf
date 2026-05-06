variable "project_name" {
  description = "Used to name and label resources created by this module"
  type        = string
}

variable "aws_region" {
  description = "The region in which to create resources"
  type        = string
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# Tagging variables
variable "owner" {
  description = "The person or team responsible for this resource"
  type        = string
  default     = "darrell"
}

variable "cost_center" {
  description = "The cost center associated with this resource"
  type        = string
  default     = "sre-lab-training"
}
