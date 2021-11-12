output "ami_id" {
  value = data.aws_ami.latest_linux.id
}

output "Login" {
  value = "ssh -i ${var.ssh_priv_key} ec2-user@${aws_instance.wordpress-ec2.public_ip}"
}

output "azs" {
  value = data.aws_availability_zones.available.*.names
}

output "db_access_from_ec2" {
  value = "mysql -h ${aws_db_instance.wordpress-db.address} -P ${aws_db_instance.wordpress-db.port} -u ${var.username} -p${var.password}"
}

output "access" {
  value = "http://${aws_instance.wordpress-ec2.public_ip}/index.php"
}
