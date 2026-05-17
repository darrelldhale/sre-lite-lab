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
echo "[1/4] Checking alarm state..."
aws cloudwatch describe-alarms \
  --alarm-names "$ALARM_5XX" \
  --region "$REGION" \
  --query "MetricAlarms[0].{State:StateValue,Reason:StateReason}" \
  --output table


# --- STEP 2: Recent 5xx Errors in Logs ---
echo ""
echo "[2/4] Querying last 10 minutes of 5xx errors in logs..."
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
echo "[3/4] Checking ECS service health..."
aws ecs describe-services \
  --cluster "$CLUSTER" \
  --services "$SERVICE" \
  --region "$REGION" \
  --query "services[0].{Running:runningCount,Desired:desiredCount,Status:status}" \
  --output table


# --- STEP 4: Last CodeDeploy Deployment ---
echo ""
echo "[4/4] Reviewing last CodeDeploy deployment..."
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
echo " 3. To find the current task definition (previous will be one revision lower):"
echo "    aws ecs describe-services \\"
echo "      --cluster $CLUSTER \\"
echo "      --services $SERVICE \\"
echo "      --region $REGION \\"
echo "      --query 'services[0].taskDefinition' --output text"
echo ""
echo ""
echo " 4. If alarm is ALARM and last deployment SUCCEEDED → create a new deployment"
echo "    pointing to the previous task definition revision in your appspec"
echo "    OR force ECS directly (faster, bypasses CodeDeploy):"
echo "    aws ecs update-service \\"
echo "      --cluster $CLUSTER \\"
echo "      --service $SERVICE \\"
echo "      --task-definition <previous-task-def-arn> \\"
echo "      --region $REGION"
echo "================================================="

