output "api_gateway_url" {
  value = aws_api_gateway_deployment.api_gateway.invoke_url
}

output "api_gateway_id" {
  value = aws_api_gateway_rest_api.api_gateway.id
}

output "api_gateway_stage" {
  value = aws_api_gateway_stage.api_gateway_stage.stage_name
}