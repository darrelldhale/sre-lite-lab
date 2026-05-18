# ADR-001 — Northwind Health Group: Architecture Decisions

**Status:** Accepted
**Date:** 2026-05
**Author:** Darrell Hale

---

## Context

Northwind Health Group is a mid-sized healthcare organization migrating from
on-premises infrastructure to AWS. Their constraints drive every decision in
this architecture:

- Lean ops team — no one available to babysit servers or respond to every alert
- HIPAA compliance — audit trails, encryption at rest, no unauthorized access
- Zero-downtime deployments — patient-facing portal cannot go dark during releases
- IaC always — no manual clicks, all infrastructure reproducible from code
- Full observability — the team must know something is wrong before patients do

---

## Decisions

### 1. ECS Fargate over EC2 Auto Scaling

**Decision:** Run the Northwind patient portal as containerized tasks on ECS
Fargate rather than EC2 instances managed by an Auto Scaling Group.

**Why:** Fargate eliminates OS patching, AMI management, and capacity planning.
The lean Northwind ops team cannot afford to maintain a fleet of EC2 instances.
Fargate self-heals failed tasks automatically, scales without intervention, and
bills only for actual compute consumed. The tradeoff is less control over the
underlying host — acceptable for a stateless web application.

---

### 2. Blue/Green Deployment over Rolling

**Decision:** Use AWS CodeDeploy blue/green deployment rather than ECS rolling
updates.

**Why:** Rolling deployments replace tasks in place — there is always a window
where old and new versions serve traffic simultaneously. For a healthcare portal,
that inconsistency is unacceptable. Blue/green runs the new version in parallel,
validates it on a test listener (port 8080) before shifting production traffic,
and rolls back in seconds if the deployment fails. The cost is two target groups
and a slightly more complex CodeDeploy configuration — worth it for the
zero-inconsistency guarantee.

---

### 3. CloudWatch over Third-Party Observability

**Decision:** Use CloudWatch Logs, Metrics, Alarms, Dashboards, and Synthetics
rather than a third-party observability platform (Datadog, New Relic, etc.).

**Why:** Northwind is early in their cloud journey and cannot justify the cost
or operational overhead of a third-party platform. CloudWatch is native to AWS,
requires no agents beyond the ECS log driver, and integrates directly with
GuardDuty, Config, and Security Hub findings. The tradeoff is less flexibility
in query language and visualization — acceptable for a lean team with a single
application.

---

### 4. Structured JSON Logging over Plain Text

**Decision:** Configure nginx to emit JSON-structured logs rather than the
default combined log format.

**Why:** Plain text logs require brittle regex patterns to extract signal. JSON
logs allow CloudWatch metric filters to target specific fields (status, request,
upstream_response_time) with exact matches. This makes the log-to-metric pipeline
reliable and maintainable. Every alarm in this system is backed by a metric
filter reading a JSON field — that would not be possible with plain text logs.

---

### 5. Synthetic Monitoring as the Primary Availability Signal

**Decision:** Run a CloudWatch Synthetics canary every minute against the ALB
as the primary availability check, in addition to reactive metric-based alarms.

**Why:** Metric-based alarms are reactive — they fire after enough bad requests
have accumulated. The canary is proactive — it detects a broken endpoint before
real users do. For a patient-facing portal, detecting failure in under 60 seconds
is a requirement, not a nice-to-have. The canary also validates the full request
path: DNS, ALB, target group, ECS task, and nginx — not just that tasks are
running.

---

### 6. AWS Security Hub as the Single Security Pane

**Decision:** Enable GuardDuty, AWS Config, and Security Hub together rather
than using each service in isolation.

**Why:** GuardDuty detects threats in flight (anomalous API calls, port scans,
credential misuse). Config detects drift in resource configuration over time
(open SSH ports, unencrypted buckets). Security Hub aggregates both into a
single findings view and benchmarks the account against the AWS Foundational
Security Best Practices standard. HIPAA requires audit evidence — Config
delivers configuration history to S3, creating a durable record of every
resource change.

---

### 7. Remote State with S3 and DynamoDB Locking

**Decision:** Store Terraform state in S3 with DynamoDB locking rather than
local state files.

**Why:** Local state cannot be shared, is not versioned, and provides no
protection against concurrent applies. S3 remote state is versioned and
encrypted. DynamoDB locking prevents two applies from running simultaneously
and corrupting state. For a team managing HIPAA infrastructure, state corruption
is not a recoverable situation — the locking table is non-negotiable.

---

## What Was Deliberately Left Out

| Capability | Decision | Reason |
|---|---|---|
| EKS | Not used | Kubernetes operational overhead exceeds Northwind's team capacity |
| Multi-region | Not implemented | Out of scope for current migration phase |
| RDS / databases | Not included | Portal serves static content in this implementation; a real patient data tier would require an application backend beyond this lab's scope |
| WAF | Not implemented | Valid next step; outside current lab scope |

---

## Consequences

This architecture gives Northwind:
- Zero-downtime deployments with instant rollback capability
- Sub-60-second availability detection via synthetic monitoring
- A complete audit trail of infrastructure changes for HIPAA compliance
- A threat detection layer that requires no manual tuning
- Full infrastructure reproducibility from a single `terraform apply`

The system is operated by runnable runbooks, monitored by a live CloudWatch
dashboard, and covered by a documented incident response playbook. A lean team
can operate it on-call without deep AWS expertise.
