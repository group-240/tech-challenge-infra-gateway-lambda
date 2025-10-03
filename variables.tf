variable "api_name" {
  description = "The name of the API Gateway"
  type        = string
  default     = "TechChallengeAPI"
}

variable "endpoint_type" {
  description = "The endpoint type for the API Gateway"
  type        = string
  default     = "REGIONAL"
}

variable "stage_name" {
  description = "The name of the deployment stage"
  type        = string
  default     = "dev"
}

variable "cors_enabled" {
  description = "Enable CORS for the API Gateway"
  type        = bool
  default     = true
}

variable "lambda_function_arns" {
  description = "List of Lambda function ARNs to integrate with the API Gateway"
  type        = list(string)
  default     = []
}

variable "lambda_function_name" {
  description = "The name of the Lambda function"
  type        = string
  default     = "jwt_authorizer"
}

variable "lambda_runtime" {
  description = "The runtime for the Lambda function"
  type        = string
  default     = "python3.8"
}

variable "api_gateway_name" {
  description = "The name of the API Gateway"
  type        = string
  default     = "jwt-authorizer-api"
}

variable "jwt_secret" {
  description = "The secret key used to verify the JWT token"
  type        = string
  default     = "mysupersecretkey"
}

variable "external_api_url" {
  description = "External API base URL"
  type        = string
  default     = "https://api.example.com"
}
  type        = string
  default     = "mysupersecretkey"
}
