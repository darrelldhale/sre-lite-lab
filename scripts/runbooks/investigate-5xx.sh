#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

echo "==================================================="
echo " NORTHWIND HEALTH GROUP RUNBOOK: HTTP 5xx Investigation"
echo " $(date -u '+%Y-%m-%d %H:%M:%S') UTC"
echo "==================================================="

# --- STEP 1: Alarm State ---
echo ""
echo "[1/5] Checking alarm state..."
aws cloudwatch describe-alarms \
  --alarm-names "$ALARM_5XX" \
  --region "$REGION" \
  --query "MetricAlarms[0].{State:StateValue,Reason:StateReason}" \
  --output table


# --- STEP 2: Recent 5xx Errors in Logs ---
echo ""
echo "[2/5] Querying last 10 minutes of 5xx errors in logs..."
QUERY_ID=$(aws logs start-query \
  --log-group-name "$LOG_GROUP" \
  --start-time "$(date -d '10 minutes ago' +%s)" \
  --end-time "$(date +%s)" \
  --query-string 'fields @timestamp, request, status, upstream_response_time | filter status >= 500 | sort @timestamp desc | limit 20' \
  --region "$REGION" \
  --output text)

sleep 3

aws logs get-query-results \
  --query-id "$QUERY_ID" \
  --region "$REGION" \
  --query "results[*][?field=='@timestamp' || field=='request' || field=='status'].value" \
  --output table


# --- STEP 3: ECS Service Health ---
echo""
echo "[3/5] Checking ECS service health..."
aws ecs describe-services \
  --cluster "$CLUSTER" \
  --services "$SERVICE" \
  --region "$REGION" \
  --query "services[0].{Running:runningCount,Desired:desiredCount,Status:status}" \
  --output table


# --- STEP 4: Last CodeDeploy Deployment ---
echo ""
echo "[4/5] Reviewing last CodeDeploy deployment..."
DEPLOYMENT_ID=$(aws deploy list-deployments \
  --application-name "$CODEDEPLOY_APP" \
  --deployment-group-name "$CODEDEPLOY_GROUP" \
  --region "$REGION" \
  --query "deployments[0]" \
  --output text)

if [ "$DEPLOYMENT_ID" == "None" ] || [ -z "$DEPLOYMENT_ID" ]; then
  echo "No deployments found for this deployment group."
else
  aws deploy get-deployment \
    --deployment-id "$DEPLOYMENT_ID" \
    --region "$REGION" \
    --query "deploymentInfo.{ID:deploymentId,Status:status,Created:createTime}" \
    --output table
fi


# --- STEP 5: Endpoint Breakdown ---
echo ""
echo "[5/5] Querying which endpoints are returning 5xx errors..."
QUERY_ID_URI=$(aws logs start-query \
  --log-group-name "$LOG_GROUP" \
  --start-time "$(date -d '10 minutes ago' +%s)" \
  --end-time "$(date +%s)" \
  --query-string 'filter status >= 500 | stats count(*) as error_count by uri | sort error_count desc | limit 10' \
  --region "$REGION" \
  --output text)

sleep 3

aws logs get-query-results \
  --query-id "$QUERY_ID_URI" \
  --region "$REGION" \
  --query "results[*][?field=='uri' || field=='error_count'].value" \
  --output table


# --- RECOMMENDATION ---
echo ""
echo "================================================="
echo " RECOMMENDED NEXT STEPS"
echo "================================================="
echo " 1. If alarm is OK → issue may have self-resolved, continue monitoring"
echo ""
echo " 2. If alarm is ALARM and a deployment is IN PROGRESS → stop and rollback:"
echo "    # Get the in-progress deployment ID:"
echo "    aws deploy list-deployments \\"
echo "      --application-name $CODEDEPLOY_APP \\"
echo "      --deployment-group-name $CODEDEPLOY_GROUP \\"
echo "      --include-only-statuses InProgress \\"
echo "      --query 'deployments[0]' --output text"
echo ""
echo "    # Then stop it and trigger auto-rollback:"
echo "    aws deploy stop-deployment --deployment-id <ID> --auto-rollback-enabled"
echo ""
echo " 3. Check which task definition revisions are currently active:"
echo "    aws ecs list-task-definitions \\"
echo "      --family-prefix $TASK_FAMILY \\"
echo "      --status ACTIVE \\"
echo "      --query 'taskDefinitionArns' \\"
echo "      --output table"
echo ""
echo ""
echo " 4. If alarm is ALARM and last deployment SUCCEEDED:"
echo ""
echo "    a. If a previous ACTIVE revision exists in step 3 output ->"
echo "       update deployment.json to point to it and trigger a new CodeDeploy deployment."
echo ""
echo "    b. If only the bad revision is active (Terraform deregistered the rest) ->"
echo "       update terraform.tfvars to the last known good image tag,"
echo "       run terraform apply, grab the new task definition ARN from the output,"
echo "       update deployment.json, and trigger a new CodeDeploy deployment."
echo "================================================="

