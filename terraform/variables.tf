variable "source_code_repo_url" {
  type        = string
  description = "Repository where IaC and Lambda function source code resides"
}

variable "environment" {
  description = "Environment the infrastructure is deployed in"
  type        = string
}

variable "cost_centre" {
  description = "Cost centre to apply the resources too"
  type        = string
}

variable "lambda_function_name" {
  type        = string
  description = "Name of lambda function"
}

variable "sns_topic_name" {
  type        = string
  description = "SNS topic name"
}

variable "runtime" {
  type        = string
  description = "Lambda runtime language and version"
}

variable "handler" {
  type        = string
  description = "Specify file & main entry point of Lambda function"
}

variable "memory_size" {
  type        = string
  description = "Size of memory to allocate Lambda function during runtime"
}

variable "timeout" {
  type        = number
  description = "Lambda function timeout"
}

variable "description" {
  type        = string
  description = "What does this stupid function do"
}

variable "gateway_name" {
  type        = string
  description = "Name of the gateway"
}

variable "gateway_description" {
  type        = string
  description = "Description of the gateway"
}

variable "authorization_type" {
  type        = string
  description = "Authorization type used to authenticate to the gateway"
}
