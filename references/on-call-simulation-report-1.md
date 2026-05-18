# On-Call Simulation Report
**Northwind Health Group — Patient Portal**
**Date:** 2026-05-17
**Engineer:** Darrell Hale
**Severity:** P2 — Patient portal returning HTTP 500 errors

---

## Scenario

A bad image (v10) was deployed to the Northwind ECS Fargate service via CodeDeploy.
The image was deliberately configured to pass ELB health checks (`/health → 200`)
while returning 500 errors to all real traffic (`/ → 500`). This simulates a
post-deployment application failure that automated rollback cannot catch.

---

## Timeline (UTC)

| Time | Event |
|------|-------|
| 17:46 | v10 (bad image) deployment triggered via CodeDeploy |
| 17:48 | `sre-lab-dev-http-5xx-too-high` alarm fires — 6 errors in 60s |
| 17:48 | SNS email notification delivered to on-call engineer |
| 17:50 | Engineer begins response — `triage.sh` run |
| 17:51 | `investigate-5xx.sh` run — 500s confirmed in logs, deployment InProgress |
| 17:51 | Attempted `stop-deployment` — deployment already completed, stop had no effect |
| 17:51 | Attempted `aws ecs update-service` — rejected, CodeDeploy controls task definition |
| 17:52 | Three CodeDeploy recovery deployments attempted — all failed (inactive task definition) |
| 17:52 | Root cause identified: Terraform deregistered old task definitions, only v10 revision active |
| ~18:05 | `terraform.tfvars` updated to v9 image, `terraform apply` run to register new task definition |
| ~18:10 | `deployment.json` updated with new task definition ARN, CodeDeploy deployment triggered |
| ~18:15 | v9 restored — patient portal serving HTTP 200, alarm cleared |

**Total incident duration:** ~25 minutes

---

## Root Cause

The bad image (v10) passed ECS health checks because the health check endpoint
(`/health`) was hardcoded to return 200, while all other routes returned 500.
CodeDeploy declared the deployment successful, making automated rollback impossible
after the fact.

When recovery was attempted, all previous task definition revisions had been
deregistered by Terraform's management of the task definition resource. Only the
active (bad) revision `:23` remained. This blocked the standard CodeDeploy rollback
path, which requires pointing to a previously registered task definition revision.

---

## What Worked

- `triage.sh` immediately identified the correct alarm and routed to the right runbook
- `investigate-5xx.sh` confirmed 500s in logs, identified the in-progress deployment,
  and provided the deployment ID and next-step guidance within seconds
- The Terraform-as-source-of-truth recovery path worked once identified — updating
  `terraform.tfvars` and applying registered a fresh active task definition for v9,
  unblocking the CodeDeploy deployment

---

## What Did Not Work

**Runbook gap — Option 4 is incorrect for CodeDeploy-managed services:**

The `investigate-5xx.sh` runbook includes this guidance:

> OR force ECS directly (faster, bypasses CodeDeploy):
> `aws ecs update-service --task-definition <arn>`

This command fails with `InvalidParameterException` when the ECS service uses a
`CODE_DEPLOY` deployment controller. CodeDeploy owns the task definition — ECS
will not accept a direct override. This option must be removed from the runbook.

**Runbook gap — No guidance for deregistered task definitions:**

The runbook assumes a previous task definition revision is available for rollback.
It does not account for the scenario where Terraform has deregistered old revisions,
leaving only the bad image active. A recovery step covering this case was missing.

---

## Runbook Fixes Required

**`scripts/runbooks/investigate-5xx.sh` — Option 4 must be updated:**

Remove the `aws ecs update-service` shortcut entirely. Replace with:

If alarm is ALARM and last deployment SUCCEEDED:
a. Check which task definition revisions are active:
aws ecs list-task-definitions
--family-prefix sre-lab-dev-ecs-task
--status ACTIVE
--query 'taskDefinitionArns'
--output table
b. If a previous active revision exists → update deployment.json to point to it
and trigger a new CodeDeploy deployment.
c. If only the bad revision is active (Terraform deregistered the rest) →
update terraform.tfvars to the last known good image tag, run terraform apply,
grab the new task definition ARN from the output, update deployment.json,
and trigger a new CodeDeploy deployment.


---

## Lessons Learned

1. **The health check bypass is a real attack surface.** Any image can be made to
   pass ELB health checks while failing real traffic. Synthetic monitoring (the canary)
   is the correct detection layer — it hits the real endpoint, not just `/health`.

2. **When Terraform manages the task definition, it is the source of truth.**
   The recovery path for a bad post-deployment failure is not "roll back CodeDeploy"
   — it is "update tfvars and re-register the good image via Terraform."

3. **The stop-deployment window is narrow.** For `CodeDeployDefault.ECSAllAtOnce`,
   the deployment completes in under a minute. Catching it in-progress requires
   immediate action the moment the alarm fires.

4. **Three failed recovery attempts cost time.** In a real P1 incident, each failed
   attempt extends patient downtime. The runbook fix in this report eliminates the
   two dead-end paths that caused the failures.


---

## Follow-Up Actions

- [ ] Update `scripts/runbooks/investigate-5xx.sh` — remove invalid `ecs update-service`
      option, add active task definition check and Terraform recovery path
- [ ] Restore `nginx.conf` from `nginx.conf.bak` — bad config should not remain as default
- [ ] Consider tagging ECR images with semantic version at build time to make
      "last known good" image identification faster during an incident

