resource "aws_ecs_cluster" "reactApp_ecs_cluster" {
  name = "reactApp-ecs-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_task_definition" "reactApp_ecs_Task_definition" {
  family                   = "reactApp-task-family"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  container_definitions    = <<TASK_DEFINITION
[
  {
    "name": "reactAppContainer",
    "image": "fatihdemirci/reactdeployment",
    "cpu": 128,
    "memory": 256,
    "essential": true,
    "portMappings": [
        {
            "containerPort": 80,
            "hostPort": 80,
            "protocol": "tcp"
        }
    ]
  }
]
TASK_DEFINITION
}

resource "aws_lb_target_group" "reactApp_alb_target_group" {
  name        = "reactApp-alb-target-group"
  target_type = "ip"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id

  health_check {
    matcher             = "200"
    path                = "/"
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    timeout             = 20
    unhealthy_threshold = 3
    protocol            = "HTTP"
  }
}

resource "aws_lb_listener" "reactApp_alb_listener" {
  load_balancer_arn = aws_lb.reactApp_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.reactApp_alb_target_group.arn
  }
}

resource "aws_lb" "reactApp_alb" {
  name               = "reactApp-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.reactApp_sg_alb.id]
  subnets            = module.vpc.public_subnets

  enable_deletion_protection = false

  depends_on = [aws_security_group.reactApp_sg_alb]
}

resource "aws_ecs_service" "reactApp_ecs_service" {
  name            = "reactApp-ecs-service"
  cluster         = aws_ecs_cluster.reactApp_ecs_cluster.id
  task_definition = aws_ecs_task_definition.reactApp_ecs_Task_definition.arn
  desired_count   = 3
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [module.vpc.public_subnets[0], module.vpc.public_subnets[1], module.vpc.public_subnets[2]]
    security_groups  = [aws_security_group.reactApp_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.reactApp_alb_target_group.arn
    container_name   = "reactAppContainer"
    container_port   = 80
  }

  depends_on = [aws_ecs_cluster.reactApp_ecs_cluster, aws_ecs_task_definition.reactApp_ecs_Task_definition, aws_security_group.reactApp_sg, aws_lb_target_group.reactApp_alb_target_group]
}
