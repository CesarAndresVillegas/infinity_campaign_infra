resource "aws_iam_role" "lambda_exec" {
  name = "${var.name}-lambda-exec"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "api" {
  function_name    = "${var.name}-api"
  role              = aws_iam_role.lambda_exec.arn
  handler           = "router.handler"
  runtime           = "nodejs22.x"
  filename          = var.package_path
  source_code_hash  = filebase64sha256(var.package_path)
  timeout           = 10

  environment {
    variables = {
      DATABASE_URL         = var.database_url
      COGNITO_USER_POOL_ID = var.cognito_user_pool_id
      COGNITO_CLIENT_ID    = var.cognito_client_id
      R2_ENDPOINT          = "https://${var.cloudflare_account_id}.r2.cloudflarestorage.com"
      R2_ACCESS_KEY_ID     = var.r2_access_key_id
      R2_SECRET_ACCESS_KEY = var.r2_secret_access_key
      R2_BUCKET_NAME       = var.r2_bucket_name
      R2_PUBLIC_URL        = var.r2_public_url
    }
  }
}

resource "aws_apigatewayv2_api" "api" {
  name          = "${var.name}-api"
  protocol_type = "HTTP"
  target        = aws_lambda_function.api.invoke_arn

  cors_configuration {
    allow_origins = [var.frontend_origin]
    allow_methods = ["GET", "POST", "DELETE"]
    allow_headers = ["content-type", "authorization"]
    max_age       = 86400
  }
}

resource "aws_lambda_permission" "apigw_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}

resource "aws_lambda_function" "post_confirmation" {
  function_name    = var.post_confirmation_function_name
  role              = aws_iam_role.lambda_exec.arn
  handler           = "handlers/auth/postConfirmation.handler"
  runtime           = "nodejs22.x"
  filename          = var.package_path
  source_code_hash  = filebase64sha256(var.package_path)
  timeout           = 10

  environment {
    variables = {
      DATABASE_URL = var.database_url
    }
  }
}

resource "aws_lambda_permission" "cognito_invoke" {
  statement_id  = "AllowCognitoInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.post_confirmation.function_name
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = var.cognito_user_pool_arn
}

resource "aws_lambda_function" "recalculate_scores" {
  function_name    = "${var.name}-recalculate-scores"
  role              = aws_iam_role.lambda_exec.arn
  handler           = "handlers/jobs/recalculateScores.handler"
  runtime           = "nodejs22.x"
  filename          = var.package_path
  source_code_hash  = filebase64sha256(var.package_path)
  timeout           = 30

  environment {
    variables = {
      DATABASE_URL = var.database_url
    }
  }
}

resource "aws_cloudwatch_event_rule" "recalculate_scores_schedule" {
  name                = "${var.name}-recalculate-scores-schedule"
  schedule_expression = "rate(1 hour)"
}

resource "aws_cloudwatch_event_target" "recalculate_scores" {
  rule = aws_cloudwatch_event_rule.recalculate_scores_schedule.name
  arn  = aws_lambda_function.recalculate_scores.arn
}

resource "aws_lambda_permission" "eventbridge_invoke" {
  statement_id  = "AllowEventBridgeInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.recalculate_scores.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.recalculate_scores_schedule.arn
}
