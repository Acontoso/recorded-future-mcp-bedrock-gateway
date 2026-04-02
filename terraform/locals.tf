locals {
  tags = merge(
    {
      "env"        = "${var.environment}"
      "terraform"  = "true"
      "bu"         = "security"
      "RepoUrl"    = "${var.source_code_repo_url}"
      "service"    = "bedrock-gateway-recordedFuture"
      "owner"      = "alex skoro"
      "author"     = "alex skoro"
      "costcentre" = "${var.cost_centre}"
    }
  )
  aws_region = "ap-southeast-2"
}
