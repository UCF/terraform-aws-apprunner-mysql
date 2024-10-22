output "CNAME_records" {
  value = values(aws_apprunner_custom_domain_association.domains).*.certificate_validation_records
}
