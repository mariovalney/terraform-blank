variable "stack_name" {
  type = string
}

variable "domain" {
  type = string
}

########################
#
# Creating SES
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ses_domain_identity
#
########################

resource "aws_ses_domain_identity" "ses_identity" {
  domain = var.domain
}

resource "aws_ses_domain_dkim" "ses_identity_dkim" {
  domain = aws_ses_domain_identity.ses_identity.domain
}
