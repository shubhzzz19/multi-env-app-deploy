# multi-env-app-deploy

Step 1: Set Up Your AWS Environment
1.1 Configure AWS CLI
aws configure
Input your AWS Access Key ID, Secret Access Key, region (e.g., us-east-1), and output format (e.g., json).

1.2 Create IAM Roles
Create IAM roles with the necessary permissions for Lambda, SQS, SNS, and RDS.
Go to IAM in the AWS Management Console.
Create a new role:
Service: Choose Lambda.
Permissions: Attach policies like AmazonSNSFullAccess, AmazonSQSFullAccess, and AmazonRDSFullAccess.
Trust Relationships: Allow Lambda to assume the role.

Step 2: Create S3 Bucket, SNS, SQS, and RDS Using Terraform
2.1 Install Terraform
2.2 Create a New Directory for Terraform Scripts
mkdir terra_infrastructure
cd terra_infrastructure
