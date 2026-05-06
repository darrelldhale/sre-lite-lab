# SRE Lab - Tagging Strategy

## Required Tags

Every resource must have the following 6 tags:

| Tag Key     | Description                         | Example              |
| ----------- | ----------------------------------- | -------------------- |
| Name        | Unique resource identifier          | sre-lab-app-server   |
| Project     | Project that owns the resource      | sre-lab              |
| Environment | Deployment environment              | dev / prod / default |
| Owner       | Person or team responsible          | darrell              |
| ManagedBy   | How the resource was provisioned    | terraform            |
| CostCenter  | Budget category for cost allocation | sre-lab-training     |

## why Each Tag is Important

**Name**: Provides a unique identifier for the resource, making it easier to manage and reference.

**Project**: Helps group resources by project, facilitating organization and cost tracking.

**Environment**: Indicates the deployment environment, which is crucial for applying appropriate policies and managing resources effectively. Enables SSM fleet manager to target specific environments.

**Owner**: Identifies the person or team responsible for the resource, which is essential for accountability and communication.

**ManagedBy**: Indicates how the resource was provisioned, which is important for understanding the resource's lifecycle and ensuring proper management.

**CostCenter**: Associates the resource with a specific budget category, enabling accurate cost allocation and tracking.

## How tags Are Applied in Terraform

A locals block in each module root defines the standard tags. All resources in that module reference the locals block.

```hcl
locals {
  tags = {
    Project     = var.project_name
    Environment = terraform.workspace
    Owner       = var.owner
    ManagedBy   = "terraform"
    CostCenter  = var.cost_center
  }
}
```

Each resource merges its Name tag with the standard tags from the locals block:

```hcl
tags = merge(
  local.tags,
  {
    Name = "${var.project_name}-app-server"
  }
)
```

## SSM Fleet Targeting

With Environment tags in place, SSM Documents can target entire fleets with one command:

Target all prod instances:
Key=tag:Environment,Values=prod

Target all dev instances:
Key=tag:Environment,Values=dev

Target by project:
Key=tag:Project,Values=sre-lab
