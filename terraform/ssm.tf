#aws kms encrypt --profile <> --key-id <kms key id> --plaintext fileb://<(echo -n 'secret') --output text --query
resource "aws_ssm_parameter" "api_key" {
  name        = "/recorded-future-mcp-gateway/opensourcekey"
  type        = "SecureString"
  description = "Open Source API key for creating SSM parameter"
  key_id      = data.aws_kms_key.cmk_ssm_alias.id
  value       = var.enc_string_recordedfuture_api_key
  tags        = local.tags
}