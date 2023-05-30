output "ses_dkim_tokens" {
  value = aws_ses_domain_dkim.ses_identity_dkim.dkim_tokens
}
