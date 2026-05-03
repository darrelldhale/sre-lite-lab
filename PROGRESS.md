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

## Month 2 — Infrastructure as Code (Planned)
- Terraform deep dive: state, modules, workspaces
- CloudFormation as backup skill
- SSM at scale
- Tagging strategies and cost accountability

## Month 3 — Compute, Containers & Deployment (Planned)
- EC2 deep dive: launch templates, AMIs, Auto Scaling Groups
- Docker fundamentals and ECS Fargate
- Blue/Green and canary deployment patterns
- Introduction to EKS

## Month 4 — Observability (Planned)
- CloudWatch the right way: structured logging, X-Ray tracing
- Real on-call dashboard
- SLIs, SLOs, error budgets
- Synthetic monitoring and canaries

## Month 5 — Incident Management & Chaos Engineering (Planned)
- Full incident response playbook
- AWS Fault Injection Simulator (FIS)
- Runnable runbooks
- On-call simulation exercises
- Backup/restore and DR testing

## Month 6 — Security, Networking & Cost (Planned)
- AWS Security Hub, GuardDuty, Config
- VPC Flow Logs
- Secrets Manager and Parameter Store
- FinOps: Cost Explorer, Budgets, rightsizing

## Month 7 — Capstone (Planned)
- Multi-tier, highly available production-grade system
- Full IaC, observability, CI/CD pipeline
- Chaos engineering with own runbooks
- Post-mortem
- SRE portfolio document
