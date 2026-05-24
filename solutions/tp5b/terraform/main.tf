################################################################################
# TP 5 — S3 hardening + KMS
#
# Objectif :
#   - bucket "data" durci (versioning, public access block, SSE-KMS, deny http)
#   - bucket "logs" qui re¸oit les access logs de "data"
#   - cle KMS dediee + alias
################################################################################

# -----------------------------------------------------------------------------
# Cle KMS dediee au chiffrement du bucket data
# -----------------------------------------------------------------------------
resource "aws_kms_key" "data" {
  description             = "${var.project} - cle de chiffrement du bucket data"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = {
    Project = var.project
  }
}

resource "aws_kms_alias" "data" {
  name          = "alias/${var.project}-data"
  target_key_id = aws_kms_key.data.key_id
}

# -----------------------------------------------------------------------------
# Bucket de logs (sert de cible aux access logs)
# -----------------------------------------------------------------------------
resource "aws_s3_bucket" "logs" {
  bucket = var.logs_bucket_name

  tags = {
    Project = var.project
    Purpose = "access-logs"
  }
}

resource "aws_s3_bucket_versioning" "logs" {
  bucket = aws_s3_bucket.logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "logs" {
  bucket                  = aws_s3_bucket.logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# -----------------------------------------------------------------------------
# Bucket de donnees (le bucket protege)
# -----------------------------------------------------------------------------
resource "aws_s3_bucket" "data" {
  bucket = var.data_bucket_name

  tags = {
    Project       = var.project
    Sensitivity   = "high"
    DataClass     = "confidential"
  }
}

resource "aws_s3_bucket_versioning" "data" {
  bucket = aws_s3_bucket.data.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "data" {
  bucket                  = aws_s3_bucket.data.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "data" {
  bucket = aws_s3_bucket.data.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.data.arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_logging" "data" {
  bucket        = aws_s3_bucket.data.id
  target_bucket = aws_s3_bucket.logs.id
  target_prefix = "data-bucket/"
}

# Bucket policy : refuse les requetes non chiffrees en transit.
data "aws_iam_policy_document" "data_secure_transport" {
  statement {
    sid    = "DenyUnencryptedTransport"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.data.arn,
      "${aws_s3_bucket.data.arn}/*",
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "data" {
  bucket = aws_s3_bucket.data.id
  policy = data.aws_iam_policy_document.data_secure_transport.json
}
