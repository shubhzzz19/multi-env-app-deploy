import os
import json
import psycopg2
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)

# Connect to PostgreSQL
def db_connection():
    return psycopg2.connect(
        host=os.environ['DB_HOST'],
        database=os.environ['DB_NAME'],
        user=os.environ['DB_USER'],
        password=os.environ['DB_PASSWORD']
    )

def lambda_handler(event, context):
    try:
        conn = db_connection()
        cursor = conn.cursor()

        for record in event['Records']:
            # Process the SQS message
            message_body = record['body']
            logging.info(f"Received message: {message_body}")

            # Insert message into the database
            cursor.execute("INSERT INTO messages (content) VALUES (%s)", (message_body,))
            logging.info("Message inserted into database.")

        conn.commit()
        cursor.close()
        conn.close()

    except Exception as e:
        logging.error(f"Error processing message: {str(e)}")
        raise e
