resource "aws_appautoscaling_target" "reactApp_autoscaling_target" {
  max_capacity       = 5
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.reactApp_ecs_cluster.name}/${aws_ecs_service.reactApp_ecs_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "reactApp_autoscaling_scale_up_policy" {
  name               = "reactApp-autoscaling-scale-up-policy"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.reactApp_autoscaling_target.resource_id
  scalable_dimension = aws_appautoscaling_target.reactApp_autoscaling_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.reactApp_autoscaling_target.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 120
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = 1
    }
  }
}

resource "aws_appautoscaling_policy" "reactApp_autoscaling_scale_down_policy" {
  name               = "reactApp_autoscaling_scale_down_policy"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.reactApp_autoscaling_target.resource_id
  scalable_dimension = aws_appautoscaling_target.reactApp_autoscaling_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.reactApp_autoscaling_target.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "reactApp_scale_up_alarm" {
  alarm_name          = "reactApp-scale-up-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  threshold           = "50"
  alarm_description   = "This metric monitors ecs cpu utilization"
  alarm_actions       = [aws_appautoscaling_policy.reactApp_autoscaling_scale_up_policy.arn]

  metric_query {
    id          = "e2"
    expression  = "SELECT AVG(CPUUtilization)FROM SCHEMA(\"AWS/ECS\", ClusterName, ServiceName)"
    label       = "CPUUtilization (Expected)"
    return_data = "true"
    period      = "60"
  }
}

resource "aws_cloudwatch_metric_alarm" "reactApp_scale_down_alarm" {
  alarm_name          = "reactApp-scale-down-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  threshold           = "20"
  alarm_description   = "This metric monitors ecs cpu utilization"
  alarm_actions       = [aws_appautoscaling_policy.reactApp_autoscaling_scale_down_policy.arn]

  metric_query {
    id          = "e1"
    expression  = "SELECT AVG(CPUUtilization)FROM SCHEMA(\"AWS/ECS\", ClusterName, ServiceName)"
    label       = "CPUUtilization (Expected)"
    return_data = "true"
    period      = "60"
  }
}
