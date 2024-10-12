provider "aws" {
    region = "us-east-1"
}

# Create an S3 bucket for logs
resource "aws_s3_bucket" "log_bucket" {
    bucket = "my-app-log-bucket-${var.environment}-123456"  # Unique bucket name for each environment
}

# Separate S3 versioning configuration (to avoid deprecation warnings)
resource "aws_s3_bucket_versioning" "log_bucket_versioning" {
    bucket = aws_s3_bucket.log_bucket.id

    versioning_configuration {
        status = "Enabled"
    }
}

# Create SNS topic
resource "aws_sns_topic" "app_topic" {
    name = "app-notification-topic-${var.environment}"
}

# Create SQS queue
resource "aws_sqs_queue" "app_queue" {
    name = "app-notification-queue-${var.environment}"
}

# Create SNS subscription to SQS
resource "aws_sns_topic_subscription" "sqs_subscription" {
    topic_arn = aws_sns_topic.app_topic.arn
    protocol  = "sqs"
    endpoint  = aws_sqs_queue.app_queue.arn
}

# Create IAM role for Lambda function
resource "aws_iam_role" "lambda_role" {
    name = "lambda_execution_role_${var.environment}"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
        Action    = "sts:AssumeRole"
        Principal = {
            Service = "lambda.amazonaws.com"
        }
        Effect   = "Allow"
        Sid      = ""
        }]
    })
}

# Attach permissions for Lambda to access SQS and RDS
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole"
    role       = aws_iam_role.lambda_role.name
}

# Create AWS RDS for PostgreSQL
resource "aws_db_instance" "app_db" {
    identifier              = "my-app-db-${var.environment}"
    engine                  = "postgres"
    engine_version          = "16.4"  # Set to the latest supported version
    instance_class          = "db.t3.micro"  # Cost-effective instance type
    allocated_storage       = 20
    db_name                 = var.db_config[var.environment].db_name
    username                = var.db_config[var.environment].username
    password                = var.db_config[var.environment].password
    parameter_group_name    = "default.postgres16"  # Update to the default parameter group for PostgreSQL 16
    skip_final_snapshot     = true
    publicly_accessible     = true
}

# Create Lambda function
resource "aws_lambda_function" "message_processor" {
    function_name = "MessageProcessor${title(var.environment)}"
    s3_bucket     = aws_s3_bucket.log_bucket.bucket
    s3_key        = "lambda.zip"  # Ensure that this is the correct path to your Lambda function code ZIP file
    handler       = "lambda_function.lambda_handler"
    runtime       = "python3.9"
    role          = aws_iam_role.lambda_role.arn

    environment {
        variables = {
        DB_HOST     = aws_db_instance.app_db.endpoint
        DB_NAME     = var.db_config[var.environment].db_name
        DB_USER     = var.db_config[var.environment].username
        DB_PASSWORD = var.db_config[var.environment].password
        }
    }
}

# Add permissions for Lambda to be triggered by SQS
resource "aws_lambda_event_source_mapping" "sqs_event_source" {
    event_source_arn = aws_sqs_queue.app_queue.arn
    function_name    = aws_lambda_function.message_processor.arn
    enabled          = true
}
