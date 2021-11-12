# ========================================================================= SECURITY GROUP DB
resource aws_security_group "rds_sg" {
  name        = "${var.project}-DBSG"
  description = "managed by terrafrom for db servers"
  vpc_id      = aws_vpc.wordpress_vpc.id
  tags   = {
    Name = "${var.project}-DBSG"
  }
  ingress = [
    {
      description      = "mysql"
      from_port        = 3306
      to_port          = 3306
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = [aws_security_group.wordpress-sg.id]
      self             = false
    }
  ]
  egress = [{
    description      = "ssh from everywhere"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = []
    self             = false
  }]
  depends_on = [
    aws_security_group.wordpress-sg]
}
# ========================================================================= SECURITY GROUP WEB
resource aws_security_group "wordpress-sg" {
  name        = "${var.project}-webSG"
  description = "This is for ${var.project}s web servers security group"
  vpc_id      = aws_vpc.wordpress_vpc.id
  tags    = {
    Name  = "${var.project}-webSG"
  }
  dynamic "ingress" {
    for_each = ["80", "443", "22"]
    content {
      description      = "ports"
      from_port        = ingress.value
      to_port          = ingress.value
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  }
  egress = [{
      description      = "ssh from everywhere"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
  }]
}
