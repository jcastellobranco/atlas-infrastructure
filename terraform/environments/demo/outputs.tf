output "instance_id" { value = aws_instance.demo.id }
output "public_ip" { value = aws_instance.demo.public_ip }
output "session_manager_hint" { value = "aws ssm start-session --target ${aws_instance.demo.id}" }
