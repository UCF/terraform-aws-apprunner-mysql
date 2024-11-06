output "DNS_records" {
  value = [for domain in aws_apprunner_custom_domain_association.domains : domain.certificate_validation_records]
  description = "CNAME records for setting DNS"
}

output "default_domain" {
  value = [for service in aws_apprunner_service.app_services : service.service_url]
  description = "The default URL where the service will be hosted."
}
