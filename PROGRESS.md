# SRE Lite Lab — Progress Tracker

## Environment
- OS: Windows with WSL (Ubuntu) in VS Code
- AWS Account: iamadmin user with admin access
- Region: us-east-1
- Terraform: v1.14.8
- GitHub: https://github.com/darrelldhale/sre-lite-lab

## Month 1 — SRE Foundations

### Week 1 ✅
- Configured AWS CLI and Terraform in WSL
- Created GitHub repo and pushed initial structure

### Week 2 ✅
- Built VPC, public/private subnets, IGW, NAT Gateway, route tables
- Built App Server (EC2) in private subnet with nginx via user_data
- Dropped Bastion in favor of SSM Session Manager for access
- Verified nginx serving HTTP 200 via SSM session
- Learned: agent forwarding, SSM vs SSH, .gitignore discipline

### Week 3 🔄 IN PROGRESS
- Building CloudWatch metrics, alarms, log shipping, and dashboard
- Files created in month-1/week-3/

### Week 4 ⏳
- Chaos engineering, CPU stress tests, runbooks, post-mortems

## Month 2 — Planned
- Docker, CI/CD with GitHub Actions, advanced Terraform

## Month 3 — Planned
- Kubernetes (EKS), SLOs/SLIs, error budgets, incident management
