output "DNS_records" {
  value = [for domain in aws_apprunner_custom_domain_association.domains : domains.certificate_validation_records]
}
