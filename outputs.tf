# ------------------------------------------------------------------
# Outputs do API Gateway
# ------------------------------------------------------------------

output "api_gateway_id" {
  description = "ID do API Gateway"
  value       = aws_api_gateway_rest_api.tech_challenge_api.id
}

output "api_gateway_name" {
  description = "Nome do API Gateway"
  value       = aws_api_gateway_rest_api.tech_challenge_api.name
}

output "api_gateway_root_resource_id" {
  description = "ID do resource root do API Gateway"
  value       = aws_api_gateway_rest_api.tech_challenge_api.root_resource_id
}

output "api_gateway_execution_arn" {
  description = "ARN de execução do API Gateway"
  value       = aws_api_gateway_rest_api.tech_challenge_api.execution_arn
}

output "api_gateway_invoke_url" {
  description = "URL de invocação do API Gateway (ambiente DEV)"
  value       = aws_api_gateway_stage.dev.invoke_url
}

output "api_gateway_stage_name" {
  description = "Nome do stage do API Gateway"
  value       = aws_api_gateway_stage.dev.stage_name
}

output "vpc_link_id" {
  description = "ID do VPC Link conectando API Gateway ao NLB"
  value       = aws_api_gateway_vpc_link.eks.id
}

output "nlb_dns_name" {
  description = "DNS name do NLB usado pelo API Gateway"
  value       = data.aws_lb.app_nlb.dns_name
}

output "cloudwatch_log_group_name" {
  description = "Nome do CloudWatch Log Group"
  value       = aws_cloudwatch_log_group.api_gateway.name
}
