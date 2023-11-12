resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "ecs-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 15
        height = 6

        properties = {
          metrics = [
            [
              {
                "expression" : "SELECT AVG(CPUUtilization) FROM SCHEMA(\"AWS/ECS\", ClusterName,ServiceName)"
              }
            ]
          ]
          period = 300
          stat   = "Average"
          region = var.region
          title  = "ECS Average CPU"
        }
      }
    ]
  })
}
