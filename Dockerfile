# Use the official Python image
FROM python:3.9-slim

# Set the working directory
WORKDIR /app

# Copy the requirements file
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the lambda function code
COPY ./dev/lambda_function.py . 

# Command to run the Lambda function (using AWS SAM CLI for local testing)
CMD ["python", "lambda_function.py"]
