resource "aws_bedrockagentcore_gateway" "example" {
  name            = var.gateway_name
  description     = var.gateway_description
  role_arn        = aws_iam_role.gateway_role.arn
  authorizer_type = var.authorization_type
  protocol_type   = "MCP"
  region          = data.aws_region.current.name
  authorizer_configuration {
    custom_jwt_authorizer {
      discovery_url    = "https://login.microsoftonline.com/${var.tenant_id}/v2.0/.well-known/openid-configuration"
      allowed_audience = var.audience_values
    }
  }
  tags = local.tags
}

resource "aws_bedrockagentcore_gateway_target" "search_malware" {
  name               = "searchMalware"
  gateway_identifier = aws_bedrockagentcore_gateway.example.gateway_id
  description        = "Query malware intelligence for one or more SHA256 file hashes. This function calls Recorded Future's malware IOC endpoint and returns a normalized list of malware attributes per matched hash."
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
            description = "Query malware intelligence for one or more SHA256 file hashes. This function calls Recorded Future's malware IOC endpoint and returns a normalized list of malware attributes per matched hash. Call this tool when you need malware metadata for known sample hashes (for example: triage enrichment, scoring, tagging, extension profiling). This strictly requires a SHA256 hash as input and will not return results for other IOC types."

            input_schema {
              type        = "object"
              description = "Input schema for malware search"

              property {
                name        = "sha256_list"
                type        = "array"
                description = "List of SHA256 hashes to search. This strictly requires a SHA256 hash as input and will not return results for other IOC types."
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
  description        = "Perform multi-type IOC enrichment for hashes, domains, and IP addresses."
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
            description = "Perform multi-type IOC enrichment for hashes, domains, and IP addresses. Use this tool for general IOC - Indicator of Compromise enrichment workflows during a security event or incident investigation, where inputs may include one or more IOC types (IP address, domain name, hash) in a single request."

            input_schema {
              type        = "object"
              description = "Input schema for IOC lookup"

              property {
                name        = "ip"
                type        = "array"
                description = "List of IP addresses,  IPv4 & IPv6 used to enrich their corresponding intelligence from Recorded Future"

                items {
                  type = "string"
                }
              }

              property {
                name        = "domain"
                type        = "array"
                description = "List of domain names used to enrich their corresponding intelligence from Recorded Future"

                items {
                  type = "string"
                }
              }

              property {
                name        = "hash"
                type        = "array"
                description = "List of hashes used to enrich their corresponding intelligence from Recorded Future. This will accept any file hash type (SHA256, MD5, SHA1) but results may vary based on the prevalence of each hash type in Recorded Future's data."

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
  description        = "Retrieve malware dynamic-analysis (sandbox) reports for a SHA256 hash."
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
            description = "Retrieve malware dynamic-analysis (sandbox) reports for a SHA256 hash. This function queries malware sandbox reports and returns behavioral analysis data such as signatures, network activity, processes, and extracted artifacts. Use this MCP tool after hash triage when detailed behavioral evidence is needed (for example: incident investigation or malware detonation context) & when you specifically need sandbox report content, not just IOC risk scoring. This strictly requires a SHA256 hash as input and will not return results for other IOC types."

            input_schema {
              type        = "object"
              description = "Input schema for sandbox search"

              property {
                name        = "hash"
                type        = "string"
                description = "SHA256 hash to search. This strictly requires a SHA256 hash as input and will not return results for other IOC types."
                required    = true
              }
            }
          }
        }
      }
    }
  }
}
