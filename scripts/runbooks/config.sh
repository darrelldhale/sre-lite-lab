#!/bin/bash
# Shared configuration file holding variables for all Northwind runbooks
# Source this file at the top of each runbook: source ./config.sh

CLUSTER="sre-lab-dev-ecs-cluster"
SERVICE="sre-lab-dev-ecs-service"
LOG_GROUP="/ecs/sre-lab/dev"
ALB_DNS="sre-lab-dev-app-load-balancer-1584247504.us-east-1.elb.amazonaws.com"
CODEDEPLOY_APP="sre-lab-dev-codedeploy-app"
CODEDEPLOY_GROUP="sre-lab-dev-codedeploy-deployment-group"
ALARM_5XX="sre-lab-dev-http-5xx-too-high"
ALARM_CPU="sre-lab-dev-ecs-cpu-too-high"
ALARM_MEMORY="sre-lab-dev-ecs-memory-too-high"
ALARM_BURN_RATE="sre-lab-dev-slo-burn-rate-too-high"
ALARM_CANARY="sre-lab-dev-canary-failed"
REGION="us-east-1"
TASK_FAMILY="sre-lab-dev-ecs-task"
