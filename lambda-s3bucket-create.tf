# ==========================================================================
# Terraform設定
# ==========================================================================
provider "aws" {
  region = "ap-northeast-1"  # お使いのリージョンに合わせて変更してください
}

# ==========================================================================
# LambdaのコードをアップロードするS3バケットの作成
# ==========================================================================
resource "aws_s3_bucket" "sample_lambda_bucket" {
  bucket = var.BucketName
  acl    = "private"
}

output "sample_lambda_bucket_arn" {
  description = "SampleLambdaS3Bucket ARN"
  value       = aws_s3_bucket.sample_lambda_bucket.arn
}
