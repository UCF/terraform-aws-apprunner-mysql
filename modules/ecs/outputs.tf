output "vitess_endpoint" {
  value = "${data.aws_network_interface.task_eni.private_ip}:15999"
  description = "The endpoint for the Vitess vtgate service."
}
