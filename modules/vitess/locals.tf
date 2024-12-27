locals {
  vitess_operator_yaml_content = file("vitess_config/operator.yaml")
  vitess_operator_yaml_docs = toset(split("---", local.vitess_operator_yaml_content))
}
