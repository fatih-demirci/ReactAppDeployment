resource "aws_security_group" "reactApp_sg" {
  name        = "reactApp-sg"
  description = "Allow 80 inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "80 rule"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks     = ["10.0.0.0/16"]
    security_groups = [aws_security_group.reactApp_sg_alb.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  depends_on = [aws_security_group.reactApp_sg_alb]
}

resource "aws_security_group" "reactApp_sg_alb" {
  name        = "reactApp-sg-alb"
  description = "Allow 80 inbound traffic for alb"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "80 rule"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
