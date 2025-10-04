variable "aws_region" {
  description = "AWS Region - fixo em us-east-1"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nome do projeto"
  type        = string
  default     = "tech-challenge"
}

variable "api_name" {
  description = "Nome do API Gateway"
  type        = string
  default     = "tech-challenge-api"
}