#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"


echo "================================================="
echo " NORTHWIND RUNBOOK: SLO Burn Rate Investigation"
echo " $(date)"
echo "================================================="

# --- STEP 1: Alarm State ---
echo ""
echo "[1/4] Checking alarm state..."
aws cloudwatch describe-alarms \
  --alarm-names "$ALARM_BURN_RATE" \
  --region "$REGION" \
  --query "MetricAlarms[0].{State:StateValue,Reason:StateReason}" \
  --output table


# --- STEP 2: Recent 5xx Count ---
echo "[2/4] Checking recent 5xx error count (last 30 minutes)..."
aws cloudwatch get-metric-statistics \
  --namespace SRELab/Nginx \
  --metric-name Http5xxCount  \
  --start-time "$(date -u -d '30 minutes ago' +%Y-%m-%dT%H:%M:%SZ)" \
  --end-time "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --period 60 \
  --statistics Sum \
  --region "$REGION" \
  --query "sort_by(Datapoints, &Timestamp)[*].{Time:Timestamp,Errors:Sum}" \
  --output table


# --- STEP 3: Recent Total Request Count ---
echo ""
echo "[3/4] Checking total request count (last 30 minutes)..."
aws cloudwatch get-metric-statistics \
  --namespace SRELab/Nginx \
  --metric-name HttpRequestCount \
  --start-time "$(date -u -d '30 minutes ago' +%Y-%m-%dT%H:%M:%SZ)" \
  --end-time "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --period 60 \
  --statistics Sum \
  --region "$REGION" \
  --query "sort_by(Datapoints, &Timestamp)[*].{Time:Timestamp,Requests:Sum}" \
  --output table


# --- STEP 4: Recent 5xx Errors in Logs ---
echo ""
echo "[4/4] Querying last 30 minutes of 5xx errors in logs..."
QUERY_ID=$(aws logs start-query \
  --log-group-name "$LOG_GROUP" \
  --start-time "$(date -d '30 minutes ago' +%s)" \
  --end-time "$(date +%s)" \
  --query-string 'fields @timestamp, request, status | filter status >= 500 | sort @timestamp desc | limit 20' \
  --region "$REGION" \
  --output text)

sleep 3

aws logs get-query-results \
  --query-id "$QUERY_ID" \
  --region "$REGION" \
  --query "results[*][?field=='@timestamp' || field=='request' || field=='status'].value" \
  --output table


# --- RECOMMENDATION ---
echo ""
echo "================================================="
echo " RECOMMENDED NEXT STEPS"
echo "================================================="
echo " REMINDER: Northwind SLO = 99.5% success rate over 30 days"
echo " Burn rate alarm fires when errors are consuming budget 14.4x faster than allowed"
echo ""
echo " 1. If alarm is OK → budget consumption has slowed, continue monitoring"
echo ""
echo " 2. Check the dashboard for live success rate and burn rate — no math needed:"
echo "    https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#dashboards:name=sre-lab-dev-dashboard"
echo ""
echo " 3. If 5xx errors are present → run the 5xx runbook for root cause:"
echo "    ./investigate-5xx.sh"
echo ""
echo " 4. If a deployment preceded the errors → rollback:"
echo "    # Get deployment ID:"
echo "    aws deploy list-deployments \\"
echo "      --application-name $CODEDEPLOY_APP \\"
echo "      --deployment-group-name $CODEDEPLOY_GROUP \\"
echo "      --include-only-statuses InProgress \\"
echo "      --query 'deployments[0]' --output text"
echo "    # Stop deployment (if needed):"
echo "    aws deploy stop-deployment --deployment-id <ID> --auto-rollback-enabled"
echo ""
