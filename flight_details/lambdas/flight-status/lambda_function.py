import boto3
from botocore.exceptions import BotoCoreError, ClientError
import json
import logging
import os
import signal
import sys

logger = logging.getLogger()
client = boto3.resource('dynamodb')
table = client.Table(os.getenv('DYNAMODB_TABLE'))


def lambda_handler(event, context):
    parameters = event['pathParameters']

    if not valid_parameters(parameters):
        return invalid_http_response()

    key = to_key(parameters)

    return to_http_response(key, request_item(key))


def request_item(key: dict[str, str]) -> dict[str, object]:
    try:
        return table.get_item(key)
    except BotoCoreError or ClientError as error:
        logging.exception("Failed to retrieve flight details from DynamoDB: %s", key)
        raise error


def valid_parameters(parameters: dict[str, str]) -> bool:
    for r in ['departure_location', 'flight_number', 'departure_date']:
        if r not in parameters:
            return False

    return True


def invalid_http_response() -> object:
    return {
        "statusCode": 400
    }


def to_http_response(key: dict[str, str], dynamodb_response: dict[str, object]) -> object:
    if 'Item' in dynamodb_response:
        logger.debug("Returning flight details for: %s", key)
        return {
            "statusCode": 200,
            "body": json.dumps(dynamodb_response['Item'])
        }
    else:
        logger.debug("Flight details not found for: %s", key)
        return {
            "statusCode": 404,
            "body": f"Item not found in table {str(key)}"
        }


def to_key(parameters: dict[str, str]) -> dict[str, str]:
    # [Departure Code]_[Flight Number]_[Planned Departure Date Herb
    dep_code = parameters['departure_location']
    flight_number = parameters['flight_number']
    dep_date = parameters['departure_date']

    return {
        'key': f'{dep_code}_{flight_number}_{dep_date}'
    }


def exit_gracefully(signum: int, frame: object) -> None:
    try:
        client.close()
    finally:
        sys.exit(0)


signal.signal(signal.SIGTERM, exit_gracefully)
