output "ec2_private_id" {
  description = "ID of EC2 Instance"
  value = { for k, v in module.ec2_instance_private : k => v.id }
}

output "ec2_private_ip" {
  description = "IP of EC2 Instance"
  value = { for k, v in module.ec2_instance_private : k => v.private_ip }
}

output "ec2_public_id" {
  description = "ID of EC2 Instance"
  value = { for k, v in module.ec2_instance_public : k => v.id }
}

output "ec2_public_ip" {
  description = "IP of EC2 Instance"
  value = { for k, v in module.ec2_instance_public : k => v.private_ip }
}

output "ec2_count_public_id" {
  description = "ID of EC2 Instance in Count"
  value = { for k, v in module.ec2_instance_public_count : k => v.id }
}

output "ec2_count_public_ip" {
  description = "IP of EC2 Instance in Count"
  value = { for k, v in module.ec2_instance_public_count : k => v.private_ip }
}

