output "vitess_endpoint" {
  value = "${data.aws_ecs_task.vitess_test.network_interface[0].private_ip}:15999"
  description = "The endpoint for the Vitess vtgate service."
}
