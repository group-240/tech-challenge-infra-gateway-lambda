# ------------------------------------------------------------------
# Remote State: Importar outputs do infra-core e application
# ------------------------------------------------------------------
data "terraform_remote_state" "core" {
  backend = "s3"
  config = {
    bucket = "tech-challenge-tfstate-533267363894-10"  # Padronizado com sufixo -10
    key    = "core/terraform.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "application" {
  backend = "s3"
  config = {
    bucket = "tech-challenge-tfstate-533267363894-10"  # Padronizado com sufixo -10
    key    = "application/terraform.tfstate"
    region = "us-east-1"
  }
}

# ------------------------------------------------------------------
# API Gateway REST API
# ------------------------------------------------------------------
resource "aws_api_gateway_rest_api" "tech_challenge_api" {
  name        = var.api_name
  description = "API for Tech Challenge - Ambiente DEV - Integração com EKS via VPC Link"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = {
    Name        = "${var.project_name}-api"
    Environment = "dev"
    ManagedBy   = "terraform"
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

resource "aws_api_gateway_method" "get_health" {
  rest_api_id   = aws_api_gateway_rest_api.tech_challenge_api.id
  resource_id   = aws_api_gateway_resource.health_check.id
  http_method   = "GET"
  authorization = "NONE" # Health check público
}

resource "aws_api_gateway_method" "get_orders" {
  rest_api_id   = aws_api_gateway_rest_api.tech_challenge_api.id
  resource_id   = aws_api_gateway_resource.order.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_method" "post_payments" {
  rest_api_id   = aws_api_gateway_rest_api.tech_challenge_api.id
  resource_id   = aws_api_gateway_resource.payment.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_method" "get_products" {
  rest_api_id   = aws_api_gateway_rest_api.tech_challenge_api.id
  resource_id   = aws_api_gateway_resource.product.id
  http_method   = "GET"
  authorization = "NONE" # Produtos públicos
}

resource "aws_api_gateway_method" "get_categories" {
  rest_api_id   = aws_api_gateway_rest_api.tech_challenge_api.id
  resource_id   = aws_api_gateway_resource.category.id
  http_method   = "GET"
  authorization = "NONE" # Categorias públicas
}

resource "aws_api_gateway_method" "get_customers" {
  rest_api_id   = aws_api_gateway_rest_api.tech_challenge_api.id
  resource_id   = aws_api_gateway_resource.customer.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_method" "post_webhooks" {
  rest_api_id   = aws_api_gateway_rest_api.tech_challenge_api.id
  resource_id   = aws_api_gateway_resource.webhook.id
  http_method   = "POST"
  authorization = "NONE" # Webhooks externos sem auth
}

# ------------------------------------------------------------------
# API Gateway Deployment e Stage
# ------------------------------------------------------------------
resource "aws_api_gateway_deployment" "tech_challenge_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.tech_challenge_api.id

  # Forçar redeployment quando resources/methods mudarem
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.category.id,
      aws_api_gateway_resource.customer.id,
      aws_api_gateway_resource.health_check.id,
      aws_api_gateway_resource.order.id,
      aws_api_gateway_resource.payment.id,
      aws_api_gateway_resource.product.id,
      aws_api_gateway_resource.webhook.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "dev" {
  deployment_id = aws_api_gateway_deployment.tech_challenge_api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.tech_challenge_api.id
  stage_name    = "dev"

  # CloudWatch Logs
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway.arn
    format = jsonencode({
      requestId      = "$context.requestId"
      ip             = "$context.identity.sourceIp"
      caller         = "$context.identity.caller"
      user           = "$context.identity.user"
      requestTime    = "$context.requestTime"
      httpMethod     = "$context.httpMethod"
      resourcePath   = "$context.resourcePath"
      status         = "$context.status"
      protocol       = "$context.protocol"
      responseLength = "$context.responseLength"
    })
  }

  tags = {
    Name        = "${var.project_name}-api-stage-dev"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}

# Account-level throttling para proteção de custos
resource "aws_api_gateway_account" "main" {
  cloudwatch_role_arn = aws_iam_role.api_gateway_cloudwatch.arn
}

resource "aws_iam_role" "api_gateway_cloudwatch" {
  name = "${var.project_name}-api-gateway-cloudwatch"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "apigateway.amazonaws.com"
      }
    }]
  })

  tags = {
    Name        = "${var.project_name}-api-gateway-role"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}

resource "aws_iam_role_policy_attachment" "api_gateway_cloudwatch" {
  role       = aws_iam_role.api_gateway_cloudwatch.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

# Method settings com throttling
resource "aws_api_gateway_method_settings" "all" {
  rest_api_id = aws_api_gateway_rest_api.tech_challenge_api.id
  stage_name  = aws_api_gateway_stage.dev.stage_name
  method_path = "*/*"

  settings {
    throttling_burst_limit = 100
    throttling_rate_limit  = 50
    logging_level          = "INFO"
    data_trace_enabled     = true
    metrics_enabled        = true
  }

  depends_on = [aws_api_gateway_stage.dev]
}

# CloudWatch Log Group para API Gateway (1 dia para custo mínimo)
resource "aws_cloudwatch_log_group" "api_gateway" {
  name              = "/aws/apigateway/${var.project_name}"
  retention_in_days = 1

  tags = {
    Name        = "${var.project_name}-api-logs"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}

# ------------------------------------------------------------------
# VPC Link: Conectar API Gateway ao NLB do infra-core
# ------------------------------------------------------------------

# VPC Link para conectar API Gateway (público) ao NLB (privado)
resource "aws_api_gateway_vpc_link" "eks" {
  name        = "${var.project_name}-vpc-link"
  description = "VPC Link para conectar API Gateway ao NLB do EKS"
  target_arns = [data.terraform_remote_state.core.outputs.nlb_arn]

  tags = {
    Name        = "${var.project_name}-vpc-link"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}

# ------------------------------------------------------------------
# Cognito Authorizer para API Gateway
# ------------------------------------------------------------------

resource "aws_api_gateway_authorizer" "cognito" {
  name            = "${var.project_name}-cognito-authorizer"
  rest_api_id     = aws_api_gateway_rest_api.tech_challenge_api.id
  type            = "COGNITO_USER_POOLS"
  provider_arns   = [data.terraform_remote_state.core.outputs.cognito_user_pool_arn]
  identity_source = "method.request.header.Authorization"
}

# ------------------------------------------------------------------
# Integrações HTTP_PROXY: API Gateway -> VPC Link -> NLB -> EKS
# ------------------------------------------------------------------

# Integração para /health
resource "aws_api_gateway_integration" "health_get" {
  rest_api_id = aws_api_gateway_rest_api.tech_challenge_api.id
  resource_id = aws_api_gateway_resource.health_check.id
  http_method = aws_api_gateway_method.get_health.http_method

  type                    = "HTTP_PROXY"
  integration_http_method = "GET"
  uri                     = "http://${data.aws_lb.app_nlb.dns_name}/api/health"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.eks.id
}

# Integração para /categories
resource "aws_api_gateway_integration" "categories_get" {
  rest_api_id = aws_api_gateway_rest_api.tech_challenge_api.id
  resource_id = aws_api_gateway_resource.category.id
  http_method = aws_api_gateway_method.get_categories.http_method

  type                    = "HTTP_PROXY"
  integration_http_method = "GET"
  uri                     = "http://${data.aws_lb.app_nlb.dns_name}/api/categories"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.eks.id
}

# Integração para /customers
resource "aws_api_gateway_integration" "customers_get" {
  rest_api_id = aws_api_gateway_rest_api.tech_challenge_api.id
  resource_id = aws_api_gateway_resource.customer.id
  http_method = aws_api_gateway_method.get_customers.http_method

  type                    = "HTTP_PROXY"
  integration_http_method = "GET"
  uri                     = "http://${data.aws_lb.app_nlb.dns_name}/api/customers"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.eks.id
}

# Integração para /orders
resource "aws_api_gateway_integration" "orders_get" {
  rest_api_id = aws_api_gateway_rest_api.tech_challenge_api.id
  resource_id = aws_api_gateway_resource.order.id
  http_method = aws_api_gateway_method.get_orders.http_method

  type                    = "HTTP_PROXY"
  integration_http_method = "GET"
  uri                     = "http://${data.aws_lb.app_nlb.dns_name}/api/orders"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.eks.id
}

# Integração para /products
resource "aws_api_gateway_integration" "products_get" {
  rest_api_id = aws_api_gateway_rest_api.tech_challenge_api.id
  resource_id = aws_api_gateway_resource.product.id
  http_method = aws_api_gateway_method.get_products.http_method

  type                    = "HTTP_PROXY"
  integration_http_method = "GET"
  uri                     = "http://${data.aws_lb.app_nlb.dns_name}/api/products"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.eks.id
}

# Integração para /payments (POST)
resource "aws_api_gateway_integration" "payments_post" {
  rest_api_id = aws_api_gateway_rest_api.tech_challenge_api.id
  resource_id = aws_api_gateway_resource.payment.id
  http_method = aws_api_gateway_method.post_payments.http_method

  type                    = "HTTP_PROXY"
  integration_http_method = "POST"
  uri                     = "http://${data.aws_lb.app_nlb.dns_name}/api/payments"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.eks.id
}

# Integração para /webhooks (POST)
resource "aws_api_gateway_integration" "webhooks_post" {
  rest_api_id = aws_api_gateway_rest_api.tech_challenge_api.id
  resource_id = aws_api_gateway_resource.webhook.id
  http_method = aws_api_gateway_method.post_webhooks.http_method

  type                    = "HTTP_PROXY"
  integration_http_method = "POST"
  uri                     = "http://${data.aws_lb.app_nlb.dns_name}/api/webhooks"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.eks.id
}