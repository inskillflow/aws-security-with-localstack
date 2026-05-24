################################################################################
# TP 3 — IAM : users, groups, roles, policies
#
# Demo pedagogique :
#   - Un groupe `developers` avec un user `alice`
#   - Un groupe `auditors` (lecture seule)
#   - Une customer-managed policy d'acces lecture sur un bucket S3 cible
#   - Un role assumable par Lambda avec une policy minimale
################################################################################

# -----------------------------------------------------------------------------
# Bucket cible utilise dans les policies. Cree ici pour que la demo soit
# autonome. Ce n'est PAS le sujet du TP, mais cela rend les ARN coherents.
# -----------------------------------------------------------------------------
resource "aws_s3_bucket" "demo" {
  bucket = var.demo_bucket_name
}

# -----------------------------------------------------------------------------
# Groupes IAM
# -----------------------------------------------------------------------------
resource "aws_iam_group" "developers" {
  name = "${var.project}-developers"
  path = "/"
}

resource "aws_iam_group" "auditors" {
  name = "${var.project}-auditors"
  path = "/"
}

# -----------------------------------------------------------------------------
# Users IAM
# -----------------------------------------------------------------------------
resource "aws_iam_user" "alice" {
  name = "${var.project}-alice"
  tags = {
    Project = var.project
    Role    = "developer"
  }
}

resource "aws_iam_user" "bob" {
  name = "${var.project}-bob"
  tags = {
    Project = var.project
    Role    = "auditor"
  }
}

# -----------------------------------------------------------------------------
# Appartenance aux groupes
# -----------------------------------------------------------------------------
resource "aws_iam_user_group_membership" "alice_membership" {
  user   = aws_iam_user.alice.name
  groups = [aws_iam_group.developers.name]
}

resource "aws_iam_user_group_membership" "bob_membership" {
  user   = aws_iam_user.bob.name
  groups = [aws_iam_group.auditors.name]
}

# -----------------------------------------------------------------------------
# Customer-managed policy : lecture sur le bucket demo
# -----------------------------------------------------------------------------
data "aws_iam_policy_document" "bucket_read" {
  statement {
    sid       = "ListBucket"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.demo.arn]
  }

  statement {
    sid       = "ReadObjects"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.demo.arn}/*"]
  }

  statement {
    sid       = "DenyUnencryptedTransport"
    effect    = "Deny"
    actions   = ["s3:*"]
    resources = [
      aws_s3_bucket.demo.arn,
      "${aws_s3_bucket.demo.arn}/*",
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_iam_policy" "bucket_read" {
  name        = "${var.project}-bucket-read"
  description = "Lecture seule sur le bucket demo, refuse le transport non chiffre."
  policy      = data.aws_iam_policy_document.bucket_read.json
}

# Attache la policy au groupe auditors (lecture seule).
resource "aws_iam_group_policy_attachment" "auditors_read" {
  group      = aws_iam_group.auditors.name
  policy_arn = aws_iam_policy.bucket_read.arn
}

# -----------------------------------------------------------------------------
# Customer-managed policy plus large : ecriture sur le bucket pour devs
# -----------------------------------------------------------------------------
data "aws_iam_policy_document" "bucket_write" {
  statement {
    sid       = "ListBucket"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.demo.arn]
  }

  statement {
    sid       = "ReadWriteObjects"
    effect    = "Allow"
    actions   = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    resources = ["${aws_s3_bucket.demo.arn}/*"]
  }
}

resource "aws_iam_policy" "bucket_write" {
  name        = "${var.project}-bucket-write"
  description = "Lecture / ecriture sur le bucket demo."
  policy      = data.aws_iam_policy_document.bucket_write.json
}

resource "aws_iam_group_policy_attachment" "developers_write" {
  group      = aws_iam_group.developers.name
  policy_arn = aws_iam_policy.bucket_write.arn
}

# -----------------------------------------------------------------------------
# Role IAM assumable par Lambda + policy d'execution minimale
# -----------------------------------------------------------------------------
data "aws_iam_policy_document" "lambda_trust" {
  statement {
    sid     = "LambdaAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_exec" {
  name               = "${var.project}-lambda-exec"
  assume_role_policy = data.aws_iam_policy_document.lambda_trust.json
  tags = {
    Project = var.project
  }
}

data "aws_iam_policy_document" "lambda_logs" {
  statement {
    sid     = "AllowCloudWatchLogs"
    effect  = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "lambda_logs_inline" {
  name   = "${var.project}-lambda-logs"
  role   = aws_iam_role.lambda_exec.id
  policy = data.aws_iam_policy_document.lambda_logs.json
}
