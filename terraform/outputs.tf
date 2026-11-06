output "alb_dns_name" {
  description = "Public DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "vpc_id" {
  description = "ID of the project VPC"
  value       = aws_vpc.main.id
}

output "instance_ids" {
  description = "IDs of the four project EC2 instances"
  value = {
    for name, instance in aws_instance.servers :
    name => instance.id
  }
}
