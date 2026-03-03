resource "aws_bedrockagentcore_gateway" "example" {
  name            = var.gateway_name
  description     = var.gateway_description
  role_arn        = aws_iam_role.gateway_role.arn
  authorizer_type = var.authorization_type
  protocol_type   = "MCP"
  region          = data.aws_region.current.name
  authorizer_configuration {
    custom_jwt_authorizer {
      discovery_url    = "https://login.microsoftonline.com/212e8b26-0a22-4ea9-b9e0-9c3dfb001559/v2.0/.well-known/openid-configuration"
      allowed_audience = ["ae4e4ead-96e7-480e-90bb-d751732811eb"]
    }
  }
  tags = local.tags
}

resource "aws_bedrockagentcore_gateway_target" "search_malware" {
  name               = "searchMalware"
  gateway_identifier = aws_bedrockagentcore_gateway.example.gateway_id
  description        = "Searches Recorded Future for malware intelligence based on SHA256 hashes"
  region             = data.aws_region.current.name

  credential_provider_configuration {
    gateway_iam_role {}
  }

  target_configuration {
    mcp {
      lambda {
        lambda_arn = aws_lambda_function.lambda.arn

        tool_schema {
          inline_payload {
            name        = "searchMalware"
            description = "Searches Recorded Future for malware intelligence based on SHA256 hashes"

            input_schema {
              type        = "object"
              description = "Input schema for malware search"

              property {
                name        = "sha256_list"
                type        = "array"
                description = "List of SHA256 hashes to search"
                required    = true

                items {
                  type = "string"
                }
              }
            }
          }
        }
      }
    }
  }
}

resource "aws_bedrockagentcore_gateway_target" "lookup_ioc" {
  name               = "lookupIOC"
  gateway_identifier = aws_bedrockagentcore_gateway.example.gateway_id
  description        = "Searches Recorded Future for IOC intelligence (IPs, domains, hashes)"
  region             = data.aws_region.current.name

  credential_provider_configuration {
    gateway_iam_role {}
  }

  target_configuration {
    mcp {
      lambda {
        lambda_arn = aws_lambda_function.lambda.arn

        tool_schema {
          inline_payload {
            name        = "lookupIOC"
            description = "Searches Recorded Future for IOC intelligence (IPs, domains, hashes)"

            input_schema {
              type        = "object"
              description = "Input schema for IOC lookup"

              property {
                name        = "ip"
                type        = "array"
                description = "List of IP addresses"

                items {
                  type = "string"
                }
              }

              property {
                name        = "domain"
                type        = "array"
                description = "List of domains"

                items {
                  type = "string"
                }
              }

              property {
                name        = "hash"
                type        = "array"
                description = "List of hashes"

                items {
                  type = "string"
                }
              }
            }
          }
        }
      }
    }
  }
}

resource "aws_bedrockagentcore_gateway_target" "search_sandbox" {
  name               = "searchSandbox"
  gateway_identifier = aws_bedrockagentcore_gateway.example.gateway_id
  description        = "Searches Recorded Future for sandbox analysis based on SHA256 hash"
  region             = data.aws_region.current.name

  credential_provider_configuration {
    gateway_iam_role {}
  }

  target_configuration {
    mcp {
      lambda {
        lambda_arn = aws_lambda_function.lambda.arn

        tool_schema {
          inline_payload {
            name        = "searchSandbox"
            description = "Searches Recorded Future for sandbox analysis based on SHA256 hash"

            input_schema {
              type        = "object"
              description = "Input schema for sandbox search"

              property {
                name        = "hash"
                type        = "string"
                description = "SHA256 hash to search"
                required    = true
              }
            }
          }
        }
      }
    }
  }
}
