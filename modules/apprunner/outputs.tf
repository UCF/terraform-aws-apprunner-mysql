output "DNS_records" {
  value = [for domain in aws_apprunner_custom_domain_association.domains : domain.certificate_validation_records]
}

output "default_domain" {
  value = [for service in aws_apprunner_service.app_services : service.service_url]
}
