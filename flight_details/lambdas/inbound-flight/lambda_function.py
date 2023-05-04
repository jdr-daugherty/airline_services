import boto3
from botocore.exceptions import BotoCoreError, ClientError
import json
import logging
import os
import signal
import sys


__all__ = []

REQUIRED_PARAMS = {'tail', 'arrival_code', 'arrival_date'}
LOGGER = logging.getLogger()
CLIENT = boto3.resource('dynamodb')
TABLE = CLIENT.Table(os.getenv('DYNAMODB_TABLE'))


# Lambda Test Event
# {
#   "pathParameters": {
#       "tail": "N413WN",
#       "arrival_code": "DAL",
#       "arrival_date": "2022-05-18"
#   }
# }
def lambda_handler(event, context):
    parameters = event['pathParameters']

    if not valid_parameters(parameters):
        return invalid_http_response()

    key = to_key(parameters)

    return to_http_response(key, request_item(key))


def request_item(key: dict[str, str]) -> dict[str, object]:
    try:
        return TABLE.get_item(Key=key)
    except BotoCoreError or ClientError as error:
        logging.exception("Failed to retrieve inbound flight status from DynamoDB: %s", key)
        raise error


def valid_parameters(parameters: dict[str, str]) -> bool:
    return REQUIRED_PARAMS.issubset(parameters.keys())


def invalid_http_response() -> object:
    return {
        "statusCode": 400
    }


def to_http_response(key: dict[str, str], dynamodb_response: dict[str, object]) -> object:
    if 'Item' in dynamodb_response:
        LOGGER.debug("Returning inbound flight status for: %s", key)
        return {
            "statusCode": 200,
            "body": json.dumps(dynamodb_response['Item'])
        }
    else:
        LOGGER.debug("Inbound flight status not found for: %s", key)
        return {
            "statusCode": 404,
            "body": f"Item not found in table {str(key)}"
        }


def to_key(parameters: dict[str, str]) -> dict[str, str]:
    tail = parameters['tail']
    arrival_code = parameters['arrival_code']
    arrival_date = parameters['arrival_date']

    return {
        'key': f'{tail}_{arrival_code}_{arrival_date}'
    }


def exit_gracefully(signum: int, frame: object) -> None:
    try:
        CLIENT.close()
    finally:
        sys.exit(0)


signal.signal(signal.SIGTERM, exit_gracefully)
