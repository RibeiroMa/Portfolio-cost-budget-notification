resource "aws_sns_topic" "budget_topic" {
  name = "notificacao-custo-50-dolares"
}

resource "aws_sns_topic_policy" "cost_budget_policy" {
  arn = aws_sns_topic.budget_topic.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "budgets.amazonaws.com"
        }
        Action   = "SNS:Publish"
        Resource = aws_sns_topic.budget_topic.arn
      }
    ]
  })
}

resource "aws_sns_topic_subscription" "sns_topic_subscription" {
  for_each  = toset(["seu email aqui", "seu email aqui"])
  topic_arn = aws_sns_topic.budget_topic.arn
  protocol  = "email"
  endpoint  = each.value
}

resource "aws_budgets_budget" "monthly_budget" {
  name         = "MonthlyCostBudget"
  budget_type  = "COST"
  limit_amount = 50
  limit_unit   = "USD"
  time_unit    = "MONTHLY"


  notification {
    comparison_operator       = "GREATER_THAN"
    threshold                 = 100
    threshold_type            = "PERCENTAGE"
    notification_type         = "ACTUAL"
    subscriber_sns_topic_arns = [aws_sns_topic.budget_topic.arn]
  }
}

