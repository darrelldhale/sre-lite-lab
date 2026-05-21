# SOA-C03 Study Plan — AWS Certified CloudOps Engineer Associate
**Darrell Hale | Target: 5–6 weeks out from 2026-05-21**

---

## Exam Facts

| Item | Detail |
|---|---|
| Exam code | SOA-C03 |
| Questions | 65 total (50 scored, 15 unscored) |
| Time | 130 minutes |
| Passing score | 720 / 1000 |
| Cost | $150 USD |
| Format | Multiple choice + multiple response |
| Delivery | Pearson VUE — testing center or online proctored |

No labs. No penalty for guessing. Compensatory scoring — you do not need to pass every domain, only the overall exam.

---

## Domain Weightings

| Domain | Weight |
|---|---|
| Domain 1: Monitoring, Logging, Analysis, Remediation, Performance Optimization | 22% |
| Domain 2: Reliability and Business Continuity | 22% |
| Domain 3: Deployment, Provisioning, and Automation | 22% |
| Domain 4: Security and Compliance | 16% |
| Domain 5: Networking and Content Delivery | 18% |

Domains 1, 2, and 3 together are 66% of the exam. Heavy focus here pays off the most.

---

## Lab Coverage Map

### Domain 1 — Monitoring, Logging, Analysis, Remediation, Performance Optimization (22%)

| Skill | Lab Coverage | Status |
|---|---|---|
| CloudWatch agent on EC2 and ECS | Month 2 Week 3, Month 5 | ✅ Strong |
| Metric filters | Month 5 Week 1 (5xx, 4xx, request count, VPC rejects) | ✅ Strong |
| CloudWatch alarms — single metric | Month 2 Week 4, Month 5 Week 2 | ✅ Strong |
| CloudWatch alarms — metric math (burn rate) | Month 5 Week 3 | ✅ Strong |
| CloudWatch dashboards | Month 5 Week 2 (6-alarm on-call dashboard) | ✅ Strong |
| SNS topics and alarm actions | Month 2, Month 5 Week 2 | ✅ Strong |
| Logs Insights queries | Month 5, Month 7 | ✅ Strong |
| SSM Automation runbooks | Month 3 Week 4 | ✅ Covered |
| Synthetic monitoring (CloudWatch Canaries) | Month 5 Week 4 | ✅ Strong |
| EventBridge rules and event routing | Not covered | ❌ Gap |
| Lambda for automated remediation | Not covered | ❌ Gap |
| EBS performance metrics and optimization | Not covered | ❌ Gap |
| S3 performance strategies | Not covered | ❌ Gap |
| RDS Performance Insights | Not covered | ❌ Gap |
| EC2 placement groups | Not covered | ❌ Gap |

**Verdict:** Strong foundation on CloudWatch monitoring stack. Study gaps: EventBridge, Lambda basics, EBS/S3/RDS performance.

---

### Domain 2 — Reliability and Business Continuity (22%)

| Skill | Lab Coverage | Status |
|---|---|---|
| Auto Scaling Groups | Month 4 Week 1 (ASG with self-healing) | ✅ Strong |
| ECS desired count and task replacement | Month 4 Week 3–4, Month 6 Week 2 | ✅ Strong |
| ALB and target group health checks | Month 4 Week 1, Month 4 Week 4 | ✅ Strong |
| Multi-AZ deployments | Networking spans 2 AZs throughout | ✅ Covered |
| Disaster recovery procedures | Month 6 Week 4 (dr-restore.sh, 27 min RTO) | ✅ Strong |
| S3 versioning | Month 3 Week 1 (tfstate bucket) | ✅ Covered |
| Blue/green deployments | Month 4 Week 4 (CodeDeploy) | ✅ Strong |
| Route 53 health checks | Not covered | ❌ Gap |
| ElastiCache caching strategy | Not covered | ❌ Gap |
| CloudFront as CDN layer | Not covered | ❌ Gap |
| AWS Backup service | Not covered | ❌ Gap |
| RDS point-in-time restore | Not covered | ❌ Gap |
| RDS Multi-AZ and read replicas | Not covered | ❌ Gap |
| DynamoDB scaling | Not covered | ❌ Gap |

**Verdict:** ASG, ALB, ECS resilience, and DR procedures are solid. Gaps are mostly database-related (RDS, DynamoDB) and Route 53/CloudFront.

---

### Domain 3 — Deployment, Provisioning, and Automation (22%)

| Skill | Lab Coverage | Status |
|---|---|---|
| Terraform (IaC) | Months 3–8 — modules, workspaces, state, backends | ✅ Strong |
| CloudFormation stacks | Month 3 Week 3 | ✅ Covered |
| AMI creation and management | Month 4 Week 1 (sre-lab-base-ami-v1) | ✅ Strong |
| Container images — ECR | Month 4 Week 3–4, Month 8 | ✅ Strong |
| Blue/green deployment | Month 4 Week 4 (CodeDeploy ECSAllAtOnce) | ✅ Strong |
| Rolling deployment | Month 4 Week 3 | ✅ Covered |
| CodeDeploy application and deployment groups | Month 4 Week 4, Month 8 | ✅ Strong |
| GitHub Actions CI/CD pipeline | Month 8 Week 2 | ✅ Strong |
| SSM for fleet automation | Month 3 Week 4 | ✅ Covered |
| Git workflows | Month 1 Week 4 | ✅ Covered |
| AWS CDK | Not covered | ❌ Gap |
| CloudFormation StackSets | Not covered | ❌ Gap |
| AWS Resource Access Manager (RAM) | Not covered | ❌ Gap |
| Lambda event-driven automation | Not covered | ❌ Gap |
| S3 Event Notifications | Not covered | ❌ Gap |
| EC2 Image Builder | Not covered | ❌ Gap |

**Verdict:** Strongest domain. Terraform, ECR, CodeDeploy, CI/CD pipeline — directly tested. CDK is a gap but expect light coverage on exam. Lambda and S3 Event Notifications worth studying.

---

### Domain 4 — Security and Compliance (16%)

| Skill | Lab Coverage | Status |
|---|---|---|
| IAM users, groups, roles, policies | Months 1–8 | ✅ Strong |
| IAM least privilege | Throughout all months | ✅ Strong |
| GuardDuty | Month 7 Week 1 | ✅ Covered |
| AWS Config rules | Month 7 Week 1 (INCOMING_SSH_DISABLED) | ✅ Covered |
| Security Hub | Month 7 Week 1 | ✅ Covered |
| CloudTrail awareness | Referenced throughout | ✅ Partial |
| AWS KMS (encryption at rest) | Not covered | ❌ Gap |
| AWS Secrets Manager | Not covered | ❌ Gap |
| AWS Certificate Manager (ACM) | Not covered (Track 3 next build) | ❌ Gap |
| Amazon Inspector | Not covered | ❌ Gap |
| IAM Access Analyzer | Not covered | ❌ Gap |
| AWS Trusted Advisor | Not covered | ❌ Gap |
| IAM Identity Center (SSO) | Not covered | ❌ Gap |
| Multi-account strategies | Not covered | ❌ Gap |
| Amazon Macie | Not covered | ❌ Gap |

**Verdict:** IAM foundation is solid. Security services (GuardDuty, Config, Security Hub) are covered at a practical level. Significant study gaps in KMS, Secrets Manager, ACM, Inspector, Trusted Advisor.

---

### Domain 5 — Networking and Content Delivery (18%)

| Skill | Lab Coverage | Status |
|---|---|---|
| VPC — subnets, route tables, IGW, NAT | Months 2–8 | ✅ Strong |
| Security groups | Months 2–8 | ✅ Strong |
| VPC Flow Logs — collection and analysis | Month 7 Week 2 | ✅ Strong |
| Private networking via SSM | Month 2 onwards | ✅ Strong |
| DNS fundamentals | Month 1 Week 3 | ✅ Covered |
| Route 53 — hosted zones, record types | Not covered | ❌ Gap |
| Route 53 — routing policies | Not covered | ❌ Gap |
| Route 53 — health checks and failover | Not covered | ❌ Gap |
| CloudFront — distributions and behaviors | Not covered | ❌ Gap |
| CloudFront — cache invalidation | Not covered | ❌ Gap |
| AWS WAF | Not covered | ❌ Gap |
| AWS Shield | Not covered | ❌ Gap |
| VPC Peering | Not covered | ❌ Gap |
| AWS PrivateLink | Not covered | ❌ Gap |
| Transit Gateway | Not covered | ❌ Gap |
| Hybrid connectivity (VPN, Direct Connect) | Not covered | ❌ Gap |

**Verdict:** VPC fundamentals and Flow Logs are solid. Route 53 and CloudFront are the most testable gaps — prioritize these. Hybrid connectivity (VPN/Direct Connect) is lower weight.

---

## Gap Priority List

Study these in order. Items at the top appear most frequently on the exam.

| Priority | Topic | Domain | Why It Matters |
|---|---|---|---|
| 1 | Route 53 — routing policies, health checks, failover | 5 | High exam weight, directly testable |
| 2 | RDS — backup, restore, Multi-AZ, read replicas, Performance Insights | 2 | Heavily tested in reliability domain |
| 3 | AWS KMS — encryption at rest, key policies | 4 | Core security concept, appears across domains |
| 4 | CloudFront — distributions, behaviors, caching, invalidation | 5 | Paired with Route 53 in networking domain |
| 5 | AWS Secrets Manager | 4 | Common security exam scenario |
| 6 | EventBridge — rules, targets, event buses | 1 | Automation and remediation scenarios |
| 7 | Lambda — basic execution, triggers, IAM role | 1, 3 | Event-driven automation |
| 8 | AWS Backup — backup plans, vaults, cross-region | 2 | Backup/restore domain |
| 9 | IAM Access Analyzer and Trusted Advisor | 4 | Security audit scenarios |
| 10 | ElastiCache — Redis, caching strategy | 2 | Scalability and performance |
| 11 | AWS CDK — basic concepts | 3 | Light coverage expected |
| 12 | VPC Peering and PrivateLink | 5 | Private networking scenarios |
| 13 | EC2 Image Builder | 3 | AMI automation alternative |

---

## Weekly Study Plan (5 Weeks)

**Time commitment:** 4 hours per week dedicated to SOA-C03
**Target exam date:** ~2026-06-25

### Week 1 (2026-05-21 to 2026-05-27)
**Theme: Networking Gaps**
- Route 53 routing policies: Simple, Weighted, Latency, Failover, Geolocation
- Route 53 health checks — how they trigger failover
- CloudFront distributions, origins, behaviors, cache policies
- CloudFront cache invalidation
- **Lab tie-in:** This maps directly to Track 3 — HTTPS/ACM/Route 53 build

### Week 2 (2026-05-28 to 2026-06-03)
**Theme: Database and Reliability**
- RDS — Multi-AZ vs read replicas (know the difference cold)
- RDS automated backups, snapshots, point-in-time restore
- RDS Performance Insights and RDS Proxy
- AWS Backup — plans, vaults, cross-region copy
- DynamoDB — on-demand vs provisioned, DAX, point-in-time recovery

### Week 3 (2026-06-04 to 2026-06-10)
**Theme: Security Gaps**
- AWS KMS — CMKs, key policies, grants, envelope encryption
- AWS Secrets Manager — secret rotation, ECS integration
- IAM Access Analyzer — findings and remediation
- AWS Trusted Advisor — five pillars, checks, alert thresholds
- Amazon Inspector — ECR scanning, EC2 scanning
- AWS Certificate Manager (ACM) — provisioning, validation, ALB attachment

### Week 4 (2026-06-11 to 2026-06-17)
**Theme: Automation Gaps**
- EventBridge — rules, event patterns, targets, event buses
- Lambda — execution model, triggers, IAM role, dead letter queues
- AWS CDK — constructs, stacks, basic deploy workflow (concepts only)
- EC2 Image Builder — pipelines, recipes, components

### Week 5 (2026-06-18 to 2026-06-24)
**Theme: Practice Exam + Weak Area Remediation**
- Take two full practice exams (Tutorials Dojo SOA-C03 — see resources below)
- Score each domain — identify where you're below 70%
- Spend remaining time on lowest-scoring domains only
- Re-read exam guide task statements for any domain below 70%
- **Exam day:** 2026-06-25 (or adjust based on practice scores)

---

## Resources

### Primary Study Material
- **Tutorials Dojo SOA-C03 Practice Exams** — best practice exam bank for this cert.
  URL: https://portal.tutorialsdojo.com/courses/aws-certified-cloudops-engineer-associate-practice-exams/
  Use section-based mode first (per domain), then timed full exams in Week 5.

- **Official AWS Exam Guide (SOA-C03)** — already reviewed. Keep it open while studying.
  URL: https://d1.awsstatic.com/onedam/marketing-channels/website/aws/en_US/certification/approved/pdfs/docs-cloudops-associate/AWS-Certified-CloudOps-Engineer-Associate_Exam-Guide.pdf

- **AWS Documentation** — for each gap topic, read the "What is" page and the FAQs.
  Better than any course for understanding how services actually work.

### Supplemental
- **Stephane Maarek SOA-C03 course (Udemy)** — if you want video content.
  Good for RDS, Route 53, and KMS sections specifically.

- **Neal Davis CloudOps Engineer Training Notes 2026** — compact reference book,
  useful for Week 5 review.

---

## How Your Lab and This Cert Work Together

Track 3 enhancements directly cover exam gaps:
- **HTTPS + ACM + Route 53** → covers Domain 4 (ACM) and Domain 5 (Route 53) gaps
- **RDS database tier** → covers Domain 2 (RDS reliability) gaps
- **Secrets Manager** → covers Domain 4 (secrets) gap
- **ElastiCache** → covers Domain 2 (caching) gap

Do not wait to finish studying before building — each Track 3 session reinforces the
concepts you studied that week. Theory on Monday, hands-on lab on Wednesday.

---

## Exam Day Checklist

- [ ] Government ID matching your Pearson VUE registration name
- [ ] Quiet room, no second monitors if online proctored
- [ ] Flag questions you are unsure of — return to them after completing all 65
- [ ] No penalty for guessing — never leave a question blank
- [ ] Time budget: ~2 minutes per question (130 min / 65 questions)
- [ ] Update OPERATIONS-LOG.md with your score and date after the exam
