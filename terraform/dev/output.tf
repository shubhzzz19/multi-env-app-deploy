output "s3_bucket_name" {
    value = aws_s3_bucket.log_bucket.bucket
}

output "sns_topic_arn" {
    value = aws_sns_topic.app_topic.arn
}

output "sqs_queue_url" {
    value = aws_sqs_queue.app_queue.id
}

output "db_endpoint" {
    value = aws_db_instance.app_db.endpoint
}
