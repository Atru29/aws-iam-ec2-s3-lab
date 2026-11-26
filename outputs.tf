output "bucket_name" {
  value = aws_s3_bucket.lab.bucket
}

output "policy_arn" {
  value = aws_iam_policy.s3_access.arn
}

output "role_name" {
  value = aws_iam_role.ec2.name
}

output "instance_id" {
  value = aws_instance.lab.id
}

output "public_ip" {
  value = aws_instance.lab.public_ip
}

output "connect_command" {
  value = "aws ec2-instance-connect ssh --instance-id ${aws_instance.lab.id} --region ${var.region}"
}

# Paso 5: comandos a pegar dentro de la EC2.
output "test_commands" {
  value = <<-EOT
    BUCKET=${aws_s3_bucket.lab.bucket}
    aws sts get-caller-identity
    aws s3 ls s3://$BUCKET
    aws s3 ls
  EOT
}
