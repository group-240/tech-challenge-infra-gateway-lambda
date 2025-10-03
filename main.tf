terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Backend S3 específico para sua conta AWS (343597913340)
  backend "s3" {
    bucket         = "tech-challenge-tfstate-lambda-gateway-343597913340"
    key            = "lambda-gateway/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tech-challenge-terraform-lock-lambda-gateway-343597913340"
    encrypt        = true
  }
}

resource "aws_api_gateway_resource" "category" {
  rest_api_id = aws_api_gateway_rest_api.tech_challenge_api.id
  parent_id   = aws_api_gateway_rest_api.tech_challenge_api.root_resource_id
  path_part   = "categories"
}

resource "aws_api_gateway_resource" "customer" {
  rest_api_id = aws_api_gateway_rest_api.tech_challenge_api.id
  parent_id   = aws_api_gateway_rest_api.tech_challenge_api.root_resource_id
  path_part   = "customers"
}

resource "aws_api_gateway_resource" "health_check" {
  rest_api_id = aws_api_gateway_rest_api.tech_challenge_api.id
  parent_id   = aws_api_gateway_rest_api.tech_challenge_api.root_resource_id
  path_part   = "health"
}

resource "aws_api_gateway_resource" "order" {
  rest_api_id = aws_api_gateway_rest_api.tech_challenge_api.id
  parent_id   = aws_api_gateway_rest_api.tech_challenge_api.root_resource_id
  path_part   = "orders"
}

resource "aws_api_gateway_resource" "payment" {
  rest_api_id = aws_api_gateway_rest_api.tech_challenge_api.id
  parent_id   = aws_api_gateway_rest_api.tech_challenge_api.root_resource_id
  path_part   = "payments"
}



# Lambda function for customers
resource "aws_lambda_function" "customers" {
  filename         = "customers.zip"
  function_name    = "get_customer_by_cpf"
  role            = "arn:aws:iam::343597913340:role/LabRole"
  handler         = "lambda_function.lambda_handler"
  runtime         = "python3.8"
  source_code_hash = filebase64sha256("customers.zip")

  environment {
    variables = {
      API_URL = var.external_api_url
    }
  }
}

# API Gateway integration for customers/{cpf}
resource "aws_api_gateway_resource" "customer_cpf" {
  rest_api_id = aws_api_gateway_rest_api.tech_challenge_api.id
  parent_id   = aws_api_gateway_resource.customer.id
  path_part   = "{cpf}"
}

resource "aws_api_gateway_method" "get_customer_by_cpf" {
  rest_api_id   = aws_api_gateway_rest_api.tech_challenge_api.id
  resource_id   = aws_api_gateway_resource.customer_cpf.id
  http_method   = "GET"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.cpf" = true
  }
}

resource "aws_api_gateway_integration" "lambda_customers" {
  rest_api_id = aws_api_gateway_rest_api.tech_challenge_api.id
  resource_id = aws_api_gateway_resource.customer_cpf.id
  http_method = aws_api_gateway_method.get_customer_by_cpf.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.customers.invoke_arn
}

# Lambda permission for API Gateway
resource "aws_lambda_permission" "apigw_lambda_customers" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.customers.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.tech_challenge_api.execution_arn}/*/*"
}

resource "aws_api_gateway_resource" "product" {
  rest_api_id = aws_api_gateway_rest_api.tech_challenge_api.id
  parent_id   = aws_api_gateway_rest_api.tech_challenge_api.root_resource_id
  path_part   = "products"
}

resource "aws_api_gateway_resource" "webhook" {
  rest_api_id = aws_api_gateway_rest_api.tech_challenge_api.id
  parent_id   = aws_api_gateway_rest_api.tech_challenge_api.root_resource_id
  path_part   = "webhooks"
}

resource "aws_api_gateway_method" "get_categories" {
  rest_api_id   = aws_api_gateway_rest_api.tech_challenge_api.id
  resource_id   = aws_api_gateway_resource.category.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "get_customers" {
  rest_api_id   = aws_api_gateway_rest_api.tech_challenge_api.id
  resource_id   = aws_api_gateway_resource.customer.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "get_health" {
  rest_api_id   = aws_api_gateway_rest_api.tech_challenge_api.id
  resource_id   = aws_api_gateway_resource.health_check.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "get_orders" {
  rest_api_id   = aws_api_gateway_rest_api.tech_challenge_api.id
  resource_id   = aws_api_gateway_resource.order.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "post_payments" {
  rest_api_id   = aws_api_gateway_rest_api.tech_challenge_api.id
  resource_id   = aws_api_gateway_resource.payment.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "get_products" {
  rest_api_id   = aws_api_gateway_rest_api.tech_challenge_api.id
  resource_id   = aws_api_gateway_resource.product.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "post_webhooks" {
  rest_api_id   = aws_api_gateway_rest_api.tech_challenge_api.id
  resource_id   = aws_api_gateway_resource.webhook.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "post_webhooks_integration" {
  rest_api_id             = aws_api_gateway_rest_api.tech_challenge_api.id
  resource_id             = aws_api_gateway_resource.webhook.id
  http_method             = aws_api_gateway_method.post_webhooks.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.authorizer.invoke_arn
}

# resource "aws_api_gateway_deployment" "tech_challenge_api_deployment" {
#   rest_api_id = aws_api_gateway_rest_api.tech_challenge_api.id
# }

resource "aws_lambda_function" "authorizer" {
  function_name = var.lambda_function_name
  role          = "arn:aws:iam::343597913340:role/LabRole" // Use the specified role ARN
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"
  filename      = "authorizer.zip"
  source_code_hash = filebase64sha256("authorizer.zip")
}

resource "aws_api_gateway_rest_api" "tech_challenge_api" {
  name        = var.api_name
  description = "API with Lambda authorizer"
}

resource "aws_api_gateway_resource" "resource" {
  rest_api_id = aws_api_gateway_rest_api.tech_challenge_api.id
  parent_id   = aws_api_gateway_rest_api.tech_challenge_api.root_resource_id
  path_part   = "protected"
}

resource "aws_api_gateway_method" "get_protected" {
  rest_api_id   = aws_api_gateway_rest_api.tech_challenge_api.id
  resource_id   = aws_api_gateway_resource.resource.id
  http_method   = "GET"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.lambda_authorizer.id
}

resource "aws_api_gateway_authorizer" "lambda_authorizer" {
  rest_api_id = aws_api_gateway_rest_api.tech_challenge_api.id
  name        = "LambdaAuthorizer"
  type        = "TOKEN"
  authorizer_uri = "${aws_lambda_function.authorizer.invoke_arn}/invocations"
  identity_source = "method.request.header.Authorization"
}

resource "aws_lambda_permission" "allow_api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.authorizer.function_name
  principal     = "apigateway.amazonaws.com"

  # The source ARN is the ARN of the API Gateway
  source_arn = "${aws_api_gateway_rest_api.tech_challenge_api.execution_arn}/*/*"
}