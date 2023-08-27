# ==========================================================================
# Terraform設定
# ==========================================================================

provider "aws" {
  region = "us-west-1"  # リージョンを適切に設定してください
}

resource "aws_iam_role" "sample_lambda_function_iam_role" {
  name = var.FunctionName

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })

  tags = {
    Name = var.FunctionName
  }
}

# ==========================================================================
# Lambdaの作成
# ==========================================================================
resource "aws_lambda_function" "sample_lambda_function" {
  filename         = "lambda.zip"  # コードファイル名を適切に指定してください
  function_name    = var.FunctionName
  role             = aws_iam_role.sample_lambda_function_iam_role.arn
  handler          = "index.handler"
  runtime          = "python3.8"
  source_code_hash = filebase64sha256("lambda.zip")  # コードファイルのハッシュを計算
}

# ==========================================================================
# APIGatewayの作成
# ==========================================================================
resource "aws_api_gateway_rest_api" "sample_api_gateway" {
  name = "SampleAPI"
}

# ==========================================================================
# API Gatewayリソース作成
# ==========================================================================
resource "aws_api_gateway_resource" "sample_api_resource" {
  rest_api_id = aws_api_gateway_rest_api.sample_api_gateway.id
  parent_id   = aws_api_gateway_rest_api.sample_api_gateway.root_resource_id
  path_part   = "myresource"
}


resource "aws_api_gateway_method" "sample_api_method" {
  rest_api_id   = aws_api_gateway_rest_api.sample_api_gateway.id
  resource_id   = aws_api_gateway_resource.sample_api_resource.id
  http_method   = "GET"
  authorization = "NONE"

  integration {
    type               = "AWS_PROXY"
    http_method        = "POST"
    uri                = aws_lambda_function.sample_lambda_function.invoke_arn
    integration_http_method = "POST"
  }
}

# ==========================================================================
# Lambda関数へのAPI Gatewayのアクセス許可
# ==========================================================================
resource "aws_lambda_permission" "sample_lambda_api_gateway_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sample_lambda_function.function_name
  principal     = "apigateway.amazonaws.com"
}

output "LambdaFunctionArn" {
  description = "Lambda Function ARN"
  value       = aws_lambda_function.sample_lambda_function.arn
}

variable "FunctionName" {
  default = "test-lambda-ver01"
}
