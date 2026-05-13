locals {
  name_prefix = "${var.project}-${var.environment}"

  common_tags = merge(var.tags, {
    Module = "observability"
  })
}

data "aws_region" "current" {}

# Metric Filter: counts every HTTP 5xx response
# Reads from the JSON log field "status"
resource "aws_cloudwatch_log_metric_filter" "http_5xx_count" {
  name           = "${local.name_prefix}-http-5xx-count"
  pattern        = "{$.status=*5*}"
  log_group_name = var.log_group_name

  metric_transformation {
    name      = "Http5xxCount"
    namespace = "SRELab/Nginx"
    value     = "1"
    unit      = "Count"
  }
}

# Metric Filter: counts every HTTP 4xx response
# Catches 404s, 403s, bad requests,etc.
resource "aws_cloudwatch_log_metric_filter" "http_4xx_count" {
  name           = "${local.name_prefix}-http-4xx-count"
  pattern        = "{$.status=*4*}"
  log_group_name = var.log_group_name

  metric_transformation {
    name      = "Http4xxCount"
    namespace = "SRELab/Nginx"
    value     = "1"
    unit      = "Count"
  }
}

# Metric Filter: counts every request regardless of status
# Used to calculate total request rate on the dashboard
resource "aws_cloudwatch_log_metric_filter" "http_requests" {
  name           = "${local.name_prefix}-http-request-count"
  pattern        = "{$.status=*}"
  log_group_name = var.log_group_name

  metric_transformation {
    name      = "HttpRequestCount"
    namespace = "SRELab/Nginx"
    value     = "1"
    unit      = "Count"
  }
}

# Metric Alarm: fires when 5xx errors exceed threshold
# This is the alarm the on-call engineer would wake up to
resource "aws_cloudwatch_metric_alarm" "http_5xx_too_high" {
  alarm_name          = "${local.name_prefix}-http-5xx-too-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "Http5xxCount"
  namespace           = "SRELab/Nginx"
  period              = "60"
  statistic           = "Sum"
  threshold           = "5"
  alarm_description   = "More than 5 HTTP 5xx errors in 60 seconds"
  treat_missing_data = "notBreaching"

  # Notify the SNS alerts topic when the alarm fires
  alarm_actions = [aws_sns_topic.alerts.arn]

  # Also notify when the alarm returns to normal - confirms the issue resolved
  ok_actions = [aws_sns_topic.alerts.arn]

  tags = local.common_tags
}

# SNS Topic: the central notification channel for all Northwind
# infrastructure alerts. Every alarm in this module will publish to this topic
resource "aws_sns_topic" "alerts" {
  name = "${local.name_prefix}-alerts"

  tags = local.common_tags
}

# SNS Subscription: delivers alarm notifications to on-call email address
# AWS will send a confirmation email - the subscription is inactive until confirmed
resource "aws_sns_topic_subscription" "alert_email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# Alarm: ECS CPU utilization too high
# Fires when average CPU across all tasks exceeds 80% for 2 consecutive minutes
# High CPU causes request slowdowns and eventual task crashes
resource "aws_cloudwatch_metric_alarm" "ecs_cpu_too_high" {
  alarm_name          = "${local.name_prefix}-ecs-cpu-too-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "ECS cluster CPU over 80% for 2 minutes"
  treat_missing_data = "notBreaching"

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.ecs_service_name
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]

  tags = local.common_tags
}

#Alarm: ECS Memory utilization too high
# Fires when average memory across all tasks exceeds 80% for 2 consecutive minutes
# memory exhaustion causes ECS to kill and restart tasks - visible as 5xx errors
resource "aws_cloudwatch_metric_alarm" "ecs_memory_too_high" {
  alarm_name          = "${local.name_prefix}-ecs-memory-too-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "ECS cluster memory over 80% for 2 minutes"
  treat_missing_data = "notBreaching"

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.ecs_service_name
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]

  tags = local.common_tags
}

# CloudWatch Dashboard — Northwind Health Group on-call view
# Single pane of glass showing HTTP health and ECS resource utilization
# Designed to answer the first question during an incident: where is the problem?
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${local.name_prefix}-dashboard"

  dashboard_body = jsonencode({
    widgets = [

      # ── Row 1: Alarm status ─────────────────────────────────────────
      {
        type   = "alarm"
        x      = 0
        y      = 0
        width  = 24
        height = 3
        properties = {
          title = "Northwind Health Group — Active Alarms"
          alarms = [
            aws_cloudwatch_metric_alarm.http_5xx_too_high.arn,
            aws_cloudwatch_metric_alarm.ecs_cpu_too_high.arn,
            aws_cloudwatch_metric_alarm.ecs_memory_too_high.arn
          ]
        }
      },

      # ── Row 2: HTTP metrics ──────────────────────────────────────────
      {
        type   = "metric"
        x      = 0
        y      = 3
        width  = 8
        height = 6
        properties = {
          title   = "Request Rate"
          region  = data.aws_region.current.name
          view    = "timeSeries"
          period  = 60
          stat    = "Sum"
          metrics = [
            ["SRELab/Nginx", "HttpRequestCount"]
          ]
        }
      },
      {
        type   = "metric"
        x      = 8
        y      = 3
        width  = 8
        height = 6
        properties = {
          title   = "4xx Errors"
          region  = data.aws_region.current.name
          view    = "timeSeries"
          period  = 60
          stat    = "Sum"
          metrics = [
            ["SRELab/Nginx", "Http4xxCount"]
          ]
        }
      },
      {
        type   = "metric"
        x      = 16
        y      = 3
        width  = 8
        height = 6
        properties = {
          title   = "5xx Errors"
          region  = data.aws_region.current.name
          view    = "timeSeries"
          period  = 60
          stat    = "Sum"
          metrics = [
            ["SRELab/Nginx", "Http5xxCount"]
          ]
        }
      },

      # ── Row 3: ECS resource health ───────────────────────────────────
      {
        type   = "metric"
        x      = 0
        y      = 9
        width  = 12
        height = 6
        properties = {
          title   = "ECS CPU Utilization"
          region  = data.aws_region.current.name
          view    = "timeSeries"
          period  = 60
          stat    = "Average"
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ClusterName", var.ecs_cluster_name, "ServiceName", var.ecs_service_name]
          ]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 9
        width  = 12
        height = 6
        properties = {
          title   = "ECS Memory Utilization"
          region  = data.aws_region.current.name
          view    = "timeSeries"
          period  = 60
          stat    = "Average"
          metrics = [
            ["AWS/ECS", "MemoryUtilization", "ClusterName", var.ecs_cluster_name, "ServiceName", var.ecs_service_name]
          ]
        }
      }
    ]
  })
}
