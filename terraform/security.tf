
# ==========================================
# Security Groups
# ==========================================

resource "aws_security_group" "alb" {
  name        = "${var.project_name}-alb-sg"
  description = "Allow public HTTP traffic to the ALB"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-alb-sg"
  }
}

resource "aws_security_group" "app" {
  name        = "${var.project_name}-app-sg"
  description = "Allow HTTP traffic from ALB"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-app-sg"
  }
}

resource "aws_security_group" "mariadb" {
  name        = "${var.project_name}-mariadb-sg"
  description = "Allow MariaDB only from application server"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-mariadb-sg"
  }
}

resource "aws_security_group" "rabbitmq" {
  name        = "${var.project_name}-rabbitmq-sg"
  description = "Allow RabbitMQ only from application server"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-rabbitmq-sg"
  }
}

resource "aws_security_group" "memcached" {
  name        = "${var.project_name}-memcached-sg"
  description = "Allow Memcached only from application server"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-memcached-sg"
  }
}

resource "aws_security_group" "elasticsearch" {
  name        = "${var.project_name}-elasticsearch-sg"
  description = "Allow Elasticsearch only from application server"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-elasticsearch-sg"
  }
}

# ==========================================
# ALB Rules
# ==========================================

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id
  description       = "HTTP from internet"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "alb_to_app" {
  security_group_id            = aws_security_group.alb.id
  description                  = "Forward traffic to application"
  ip_protocol                  = "tcp"
  from_port                    = 8080
  to_port                      = 8080
  referenced_security_group_id = aws_security_group.app.id
}

# ==========================================
# Application Server Rules
# ==========================================

resource "aws_vpc_security_group_ingress_rule" "app_from_alb" {
  security_group_id            = aws_security_group.app.id
  description                  = "HTTP from ALB"
  ip_protocol                  = "tcp"
  from_port                    = 8080
  to_port                      = 8080
  referenced_security_group_id = aws_security_group.alb.id
}

resource "aws_vpc_security_group_egress_rule" "app_outbound" {
  security_group_id = aws_security_group.app.id
  description       = "Allow outbound traffic"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

# ==========================================
# Backend Server Inbound Rules
# ==========================================

resource "aws_vpc_security_group_ingress_rule" "mariadb_from_app" {
  security_group_id            = aws_security_group.mariadb.id
  description                  = "MariaDB from app"
  ip_protocol                  = "tcp"
  from_port                    = 3306
  to_port                      = 3306
  referenced_security_group_id = aws_security_group.app.id
}

resource "aws_vpc_security_group_ingress_rule" "rabbitmq_from_app" {
  security_group_id            = aws_security_group.rabbitmq.id
  description                  = "AMQP from app"
  ip_protocol                  = "tcp"
  from_port                    = 5672
  to_port                      = 5672
  referenced_security_group_id = aws_security_group.app.id
}

resource "aws_vpc_security_group_ingress_rule" "memcached_from_app" {
  security_group_id            = aws_security_group.memcached.id
  description                  = "Memcached from app"
  ip_protocol                  = "tcp"
  from_port                    = 11211
  to_port                      = 11211
  referenced_security_group_id = aws_security_group.app.id
}

resource "aws_vpc_security_group_ingress_rule" "elasticsearch_from_app" {
  security_group_id            = aws_security_group.elasticsearch.id
  description                  = "Elasticsearch transport traffic from app"
  ip_protocol                  = "tcp"
  from_port                    = 9300
  to_port                      = 9300
  referenced_security_group_id = aws_security_group.app.id
}

# ==========================================
# Backend Server Outbound Rules
# ==========================================

resource "aws_vpc_security_group_egress_rule" "mariadb_https" {
  security_group_id = aws_security_group.mariadb.id
  description       = "HTTPS outbound for updates and SSM"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "mariadb_http" {
  security_group_id = aws_security_group.mariadb.id
  description       = "HTTP outbound for package repositories"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "rabbitmq_https" {
  security_group_id = aws_security_group.rabbitmq.id
  description       = "HTTPS outbound for updates and SSM"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "rabbitmq_http" {
  security_group_id = aws_security_group.rabbitmq.id
  description       = "HTTP outbound for package repositories"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "memcached_https" {
  security_group_id = aws_security_group.memcached.id
  description       = "HTTPS outbound for updates and SSM"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "memcached_http" {
  security_group_id = aws_security_group.memcached.id
  description       = "HTTP outbound for package repositories"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "elasticsearch_https" {
  security_group_id = aws_security_group.elasticsearch.id
  description       = "HTTPS outbound for SSM and downloads"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "elasticsearch_http" {
  security_group_id = aws_security_group.elasticsearch.id
  description       = "HTTP outbound for package repositories"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"
}
