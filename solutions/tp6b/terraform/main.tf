################################################################################
# TP 6 — CloudWatch Logs + Metric Filter + Alarm
#
# Objectif :
#   - log group applicatif avec retention controlee
#   - metric filter qui compte les motifs "Unauthorized" et "Denied"
#   - alarm qui se declenche au-dela d'un seuil
#   - SNS topic comme cible d'alarme (non envoye reellement en LocalStack)
################################################################################

# -----------------------------------------------------------------------------
# Log group applicatif
# -----------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "app" {
  name              = "/secdemo/app"
  retention_in_days = var.log_group_retention_days

  tags = {
    Project = var.project
  }
}

# -----------------------------------------------------------------------------
# Metric filter : compte les lignes contenant "Unauthorized"
# -----------------------------------------------------------------------------
resource "aws_cloudwatch_log_metric_filter" "unauthorized" {
  name           = "${var.project}-unauthorized-count"
  log_group_name = aws_cloudwatch_log_group.app.name
  pattern        = "Unauthorized"

  metric_transformation {
    name      = "UnauthorizedCount"
    namespace = "Security/App"
    value     = "1"
    unit      = "Count"
  }
}

# -----------------------------------------------------------------------------
# Metric filter : compte les lignes contenant "Denied"
# -----------------------------------------------------------------------------
resource "aws_cloudwatch_log_metric_filter" "denied" {
  name           = "${var.project}-denied-count"
  log_group_name = aws_cloudwatch_log_group.app.name
  pattern        = "Denied"

  metric_transformation {
    name      = "DeniedCount"
    namespace = "Security/App"
    value     = "1"
    unit      = "Count"
  }
}

# -----------------------------------------------------------------------------
# SNS topic pour les notifications d'alarme
# -----------------------------------------------------------------------------
resource "aws_sns_topic" "security_alerts" {
  name = "${var.project}-security-alerts"
}

# -----------------------------------------------------------------------------
# Alarm : trop de "Unauthorized" sur 1 minute
# -----------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "too_many_unauthorized" {
  alarm_name          = "${var.project}-too-many-unauthorized"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "UnauthorizedCount"
  namespace           = "Security/App"
  period              = 60
  statistic           = "Sum"
  threshold           = var.alarm_threshold_unauthorized
  treat_missing_data  = "notBreaching"
  alarm_description   = "Plus de ${var.alarm_threshold_unauthorized} 'Unauthorized' sur 1 minute."
  alarm_actions       = [aws_sns_topic.security_alerts.arn]
  ok_actions          = [aws_sns_topic.security_alerts.arn]
}
