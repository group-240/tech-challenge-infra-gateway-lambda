variable "api_name" {
  description = "The name of the API Gateway"
  type        = string
}

variable "endpoint_type" {
  description = "The endpoint type for the API Gateway"
  type        = string
  default     = "REGIONAL"
}

variable "stage_name" {
  description = "The name of the deployment stage"
  type        = string
  default     = "prod"
}

variable "cors_enabled" {
  description = "Enable CORS for the API Gateway"
  type        = bool
  default     = true
}

variable "lambda_function_arns" {
  description = "List of Lambda function ARNs to integrate with the API Gateway"
  type        = list(string)
}