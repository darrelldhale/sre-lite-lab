#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

echo "==================================================="
echo " NORTHWIND HEALTH GROUP RUNBOOK: ECS CPU Investigation"
echo " $(date -u '+%Y-%m-%d %H:%M:%S') UTC"
echo "==================================================="

# --- STEP 1: Alarm State ---
echo ""
echo "[1/4] Checking alarm state..."
aws cloudwatch describe-alarms \
  --alarm-names "$ALARM_CPU" \
  --region "$REGION" \
  --query "MetricAlarms[0].{State:StateValue,Reason:StateReason}" \
  --output table


# --- STEP 2: Current CPU Utilization ---
echo ""
echo "[2/4] Checking ECS CPU utilization (last 10 minutes)..."
aws cloudwatch get-metric-statistics \
  --namespace AWS/ECS \
  --metric-name CPUUtilization \
  --dimensions Name=ClusterName,Value="$CLUSTER" Name=ServiceName,Value="$SERVICE" \
  --start-time "$(date -u -d '10 minutes ago' '+%Y-%m-%dT%H:%M:%S')" \
  --end-time "$(date -u '+%Y-%m-%dT%H:%M:%S')" \
  --period 60 \
  --statistics Average Maximum \
  --region "$REGION" \
  --query "sort_by(Datapoints,&Timestamp)[*].{Time:Timestamp, AvgCPU:Average, MaxCPU:Maximum}" \
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


# --- STEP 4: Recent ECS Service Events ---
echo ""
echo "[4/4] Checking recent ECS service events..."
aws ecs describe-services \
  --cluster "$CLUSTER" \
  --services "$SERVICE" \
  --region "$REGION" \
  --query "services[0].events[:5].{Time:createdAt,Message:message}" \
  --output table


# --- RECOMMENDATION ---
echo ""
echo "================================================="
echo " RECOMMENDED NEXT STEPS"
echo "================================================="
echo " 1. If alarm is OK → issue may have self-resolved, continue monitoring"
echo ""
echo " 2. If CPU is high and Running < Desired → tasks are crashing, check ECS logs:"
echo "    aws logs tail $LOG_GROUP --since 10m --region $REGION \\"
echo "      | grep -iE 'timeout|timed out|connection refused|too many requests|rate limit|worker|thread|cpu'"
echo ""
echo " 3. If CPU is high and Running == Desired → app is overloaded, scale out:"
echo "    aws ecs update-service \\"
echo "      --cluster $CLUSTER \\"
echo "      --service $SERVICE \\"
echo "      --desired-count 4 \\"
echo "      --region $REGION"
echo ""
echo " 4. If CPU spike followed a deployment → consider rollback:"
echo "    # Get deployment ID:"
echo "    aws deploy list-deployments \\"
echo "      --application-name $CODEDEPLOY_APP \\"
echo "      --deployment-group-name $CODEDEPLOY_GROUP \\"
echo "      --include-only-statuses InProgress \\"
echo "      --query 'deployments[0]' --output text"
echo "    # Stop deployment:"
echo "    aws deploy stop-deployment --deployment-id <ID> --auto-rollback-enabled"
echo "================================================="

