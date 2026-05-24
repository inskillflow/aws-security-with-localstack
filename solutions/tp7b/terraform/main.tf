################################################################################
# TP 7 — Auto-remediation S3 via Lambda + EventBridge
#
# Pipeline :
#   1. Un appel S3:CreateBucket genere un evenement CloudTrail
#   2. EventBridge route cet evenement vers une Lambda
#   3. La Lambda applique le `public access block` sur le bucket cree
#
# Note LocalStack : la propagation CloudTrail vers EventBridge est limitee
# en plan gratuit. On fournit deux modes :
#   - en theorie : la regle declenche la Lambda
#   - en pratique : on invoque la Lambda manuellement avec un payload de test
################################################################################

# -----------------------------------------------------------------------------
# Package Lambda
# -----------------------------------------------------------------------------
data "archive_file" "remediation_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../lambda"
  output_path = "${path.module}/build/remediation.zip"
}

# -----------------------------------------------------------------------------
# IAM : trust + permissions de la Lambda
# -----------------------------------------------------------------------------
data "aws_iam_policy_document" "lambda_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "remediation" {
  name               = "${var.project}-remediation-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_trust.json
}

data "aws_iam_policy_document" "remediation_inline" {
  statement {
    sid    = "AllowS3PublicAccessBlock"
    effect = "Allow"
    actions = [
      "s3:GetPublicAccessBlock",
      "s3:PutPublicAccessBlock",
      "s3:ListAllMyBuckets",
    ]
    resources = ["*"]
  }
  statement {
    sid    = "AllowLogging"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "remediation_inline" {
  name   = "${var.project}-remediation-inline"
  role   = aws_iam_role.remediation.id
  policy = data.aws_iam_policy_document.remediation_inline.json
}

# -----------------------------------------------------------------------------
# Lambda
# -----------------------------------------------------------------------------
resource "aws_lambda_function" "remediation" {
  function_name    = "${var.project}-s3-remediation"
  role             = aws_iam_role.remediation.arn
  handler          = "handler.lambda_handler"
  runtime          = var.lambda_runtime
  filename         = data.archive_file.remediation_zip.output_path
  source_code_hash = data.archive_file.remediation_zip.output_base64sha256
  timeout          = 30

  environment {
    variables = {
      LOG_LEVEL = "INFO"
    }
  }

  tags = {
    Project = var.project
  }
}

# -----------------------------------------------------------------------------
# EventBridge : regle qui matche `S3 CreateBucket` via CloudTrail
# -----------------------------------------------------------------------------
resource "aws_cloudwatch_event_rule" "on_create_bucket" {
  name        = "${var.project}-on-create-bucket"
  description = "Route les evenements S3:CreateBucket vers la Lambda d'auto-remediation."

  event_pattern = jsonencode({
    source        = ["aws.s3"]
    "detail-type" = ["AWS API Call via CloudTrail"]
    detail = {
      eventSource = ["s3.amazonaws.com"]
      eventName   = ["CreateBucket"]
    }
  })
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.on_create_bucket.name
  target_id = "${var.project}-lambda"
  arn       = aws_lambda_function.remediation.arn
}

resource "aws_lambda_permission" "allow_events" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.remediation.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.on_create_bucket.arn
}
