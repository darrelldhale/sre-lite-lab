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

### Week 3 ✅
- Created SNS topic and email subscription for alerts
- Built CloudWatch CPU alarm (triggers >80% for 4 minutes)
- Built CloudWatch log group and nginx 4xx metric filter
- Built CloudWatch dashboard with CPU and error widgets
- Installed and configured CloudWatch agent on App Server via SSM
- Verified nginx logs shipping to CloudWatch log group
- Learned: data sources, IAM policy attachments, CloudWatch agent config

### Week 4 ✅
- Installed stress tooling on App Server via SSM
- Diagnosed and fixed misconfigured CloudWatch alarm dimensions
- Successfully triggered CPU alarm above 80% threshold
- Received ALARM and OK email notifications via SNS
- Wrote runbook for high CPU incident response
- Wrote post-mortem documenting root cause and lessons learned
- Learned: chaos engineering, CPU burst credits, alarm dimensions,
  incident documentation

## Month 2 — Planned
- Docker, CI/CD with GitHub Actions, advanced Terraform

## Month 3 — Planned
- Kubernetes (EKS), SLOs/SLIs, error budgets, incident management
