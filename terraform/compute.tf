
locals {
  servers = {
    app = {
      subnet_id         = aws_subnet.public.id
      security_group_id = aws_security_group.app.id
      public_ip         = true
      instance_type     = "t3.micro"
    }
    mariadb = {
      subnet_id         = aws_subnet.private.id
      security_group_id = aws_security_group.mariadb.id
      public_ip         = false
      instance_type     = "t3.micro"
    }
    rabbitmq = {
      subnet_id         = aws_subnet.private.id
      security_group_id = aws_security_group.rabbitmq.id
      public_ip         = false
      instance_type     = "t3.micro"
    }
    memcached = {
      subnet_id         = aws_subnet.private.id
      security_group_id = aws_security_group.memcached.id
      public_ip         = false
      instance_type     = "t3.micro"
    }
    elasticsearch = {
      subnet_id         = aws_subnet.private.id
      security_group_id = aws_security_group.elasticsearch.id
      public_ip         = false
      instance_type     = "t3.small"
    }
  }
}

# IAM Role for EC2 Systems Manager access
resource "aws_iam_role" "ec2_ssm" {
  name = "${var.project_name}-ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name = "${var.project_name}-ec2-ssm-role"
  }
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ec2_ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2" {
  name = "${var.project_name}-ec2-profile"
  role = aws_iam_role.ec2_ssm.name
}

# Five project servers
resource "aws_instance" "servers" {
  for_each = local.servers

  ami           = "ami-06fb1802e2b757f09"
  instance_type = each.value.instance_type

  subnet_id                   = each.value.subnet_id
  vpc_security_group_ids      = [each.value.security_group_id]
  associate_public_ip_address = each.value.public_ip

  iam_instance_profile = aws_iam_instance_profile.ec2.name

  root_block_device {
    volume_size           = 8
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = {
    Name    = "${var.project_name}-${each.key}"
    Project = var.project_name
    Role    = each.key
  }
}

# Register the application server with the ALB target group
resource "aws_lb_target_group_attachment" "app" {
  target_group_arn = aws_lb_target_group.app.arn
  target_id        = aws_instance.servers["app"].id
  port             = 8080
}
