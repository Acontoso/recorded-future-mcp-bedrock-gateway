module "sns" {
  source  = "cloudposse/sns-topic/aws"
  version = "0.21.0" #github release, linked to commit hash

  name                                   = var.sns_topic_name
  allowed_aws_services_for_sns_published = ["lambda.amazonaws.com"]
  encryption_enabled                     = false

  subscribers = {
    aesopinternal = {
      protocol               = "email"
      endpoint               = "securityengineering@wesfarmershealth.com.au"
      endpoint_auto_confirms = false
      raw_message_delivery   = false
    }
  }

  sqs_dlq_enabled = false
  tags            = local.tags
}
