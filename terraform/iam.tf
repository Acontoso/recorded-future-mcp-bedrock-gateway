#################################Lambda####################################
data "aws_iam_policy_document" "trust_policy_document_lambda" {
  statement {
    sid    = "LambdaTrustPolicy"
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      identifiers = [
        "lambda.amazonaws.com",
      ]

      type = "Service"
    }
  }
}

data "aws_iam_policy_document" "lambda_custom_execution_policy" {
  version = "2012-10-17"
  statement {
    sid    = "AllowSSM"
    effect = "Allow"
    actions = [
      "ssm:GetParameter*"
    ]
    resources = [
      aws_ssm_parameter.api_key.arn
    ]
  }
  statement {
    sid    = "AllowSnsPublish"
    effect = "Allow"
    actions = [
      "sns:Publish",
    ]
    resources = [
      module.sns.sns_topic_arn
    ]
  }
  statement {
    sid    = "AllowKMS"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
    ]
    resources = [
      data.aws_kms_key.ssm_kms_alias.arn
    ]
  }
}

resource "aws_iam_policy" "lambda_iam_policy" {
  name   = "recorded-future-lambda-policy"
  policy = data.aws_iam_policy_document.lambda_custom_execution_policy.json
  tags   = local.tags
}

resource "aws_iam_policy_attachment" "lambda_policy_attachment_role" {
  name       = "role-policy-attachment"
  roles      = [aws_iam_role.lambda_role.name]
  policy_arn = aws_iam_policy.lambda_iam_policy.arn
}

resource "aws_iam_role" "lambda_role" {
  name               = "recorded-future-lambda-execution-role"
  assume_role_policy = data.aws_iam_policy_document.trust_policy_document_lambda.json
  tags               = local.tags
}

resource "aws_iam_role_policy_attachment" "default_policy_attachment_lambda_role" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

############################Gateway####################################

data "aws_iam_policy_document" "assume_role_gateway" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["bedrock-agentcore.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "gateway_custom_execution_policy" {
  version = "2012-10-17"
  statement {
    sid    = "AmazonBedrockAgentCoreGatewayLambdaProd"
    effect = "Allow"
    actions = [
      "lambda:InvokeFunction"
    ]
    resources = [
      aws_lambda_function.lambda.arn
    ]
  }
}

resource "aws_iam_policy" "gateway_iam_policy" {
  name   = "recorded-future-gateway-policy"
  policy = data.aws_iam_policy_document.gateway_custom_execution_policy.json
  tags   = local.tags
}

resource "aws_iam_policy_attachment" "gateway_policy_attachment_role" {
  name       = "role-policy-attachment-gateway"
  roles      = [aws_iam_role.gateway_role.name]
  policy_arn = aws_iam_policy.gateway_iam_policy.arn
}

resource "aws_iam_role" "gateway_role" {
  name               = "bedrock-agentcore-gateway-role-recorded-future"
  assume_role_policy = data.aws_iam_policy_document.assume_role_gateway.json
}

resource "aws_iam_role_policy_attachment" "default_policy_attachment_lambda_role_gateway" {
  role       = aws_iam_role.gateway_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
