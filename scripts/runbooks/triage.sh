#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

echo "================================================="
echo " NORTHWIND HEALTH GROUP TRIAGE — All Alarm Status"
echo " $(date)"
echo "================================================="

echo ""
echo "Checking all 5 alarms..."
echo ""

aws cloudwatch describe-alarms \
  --alarm-names \
    "$ALARM_5XX" \
    "$ALARM_CPU" \
    "$ALARM_MEMORY" \
    "$ALARM_BURN_RATE" \
    "$ALARM_CANARY" \
  --region "$REGION" \
  --query "MetricAlarms[*].{Alarm:AlarmName,State:StateValue,Reason:StateReason}" \
  --output table

echo ""
echo "================================================="
echo " RUNBOOK ROUTING"
echo "================================================="
echo " sre-lab-dev-http-5xx-too-high    → ./investigate-5xx.sh"
echo " sre-lab-dev-ecs-cpu-too-high     → ./investigate-cpu.sh"
echo " sre-lab-dev-ecs-memory-too-high  → ./investigate-memory.sh"
echo " sre-lab-dev-slo-burn-rate-too-high → ./investigate-burn-rate.sh"
echo " sre-lab-dev-canary-failed        → ./investigate-canary.sh"
echo ""
echo " Dashboard:"
echo " https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#dashboards:name=sre-lab-dev-dashboard"
echo "================================================="
