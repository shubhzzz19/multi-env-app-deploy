variable "environment" {
    description = "The environment to deploy (dev, staging, prod)"
    type        = string
    validation {
        condition     = contains(["dev", "staging", "prod"], var.environment)
        error_message = "Environment must be one of: dev, staging, prod."
    }
}

variable "db_config" {
    description = "Database configuration for each environment"
    type        = map(object({
        username = string
        password = string
        db_name  = string
    }))
    default = {
        dev = {
            username = "your_dev_db_username"
            password = "your_dev_db_password"  # Consider using sensitive variables or secrets
            db_name  = "appdb_dev"
        }
        staging = {
            username = "your_staging_db_username"
            password = "your_staging_db_password"  # Consider using sensitive variables or secrets
            db_name  = "appdb_staging"
        }
        prod = {
            username = "your_prod_db_username"
            password = "your_prod_db_password"  # Consider using sensitive variables or secrets
            db_name  = "appdb_prod"
        }
    }
}
