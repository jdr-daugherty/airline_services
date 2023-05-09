import boto3
from botocore.exceptions import BotoCoreError, ClientError
import json
import logging
import os
import signal
import sys


REQUIRED_PARAMS = {'tail', 'arrival_code', 'arrival_date'}

try:
    LOGGER = logging.getLogger()
    LOGGER.setLevel(logging.INFO)
    CLIENT = boto3.resource('dynamodb')
    TABLE = CLIENT.Table(os.getenv('DYNAMODB_TABLE'))
except Exception as ex:
    LOGGER.exception("Failed to initialize lambda")
    raise ex


# Lambda Test Event
# {
#   "pathParameters": {
#       "tail": "N413WN",
#       "arrival_code": "DAL",
#       "arrival_date": "2022-05-18"
#   }
# }
def lambda_handler(event, context):
    if 'queryStringParameters' not in event:
        LOGGER.info("Invalid parameters: %s", event)
        return invalid_http_response(None)

    parameters = event['queryStringParameters']

    if not valid_parameters(parameters):
        LOGGER.info("Invalid parameters: %s", str(parameters))
        return invalid_http_response(parameters)

    key = to_key(parameters)

    return to_http_response(key, request_item(key))


def request_item(key: dict[str, str]) -> dict[str, object]:
    try:
        return TABLE.get_item(Key=key)
    except BotoCoreError or ClientError as error:
        logging.exception("Failed to retrieve inbound flight status from DynamoDB: %s", key)
        raise error


def valid_parameters(parameters: dict[str, str]) -> bool:
    return parameters is not None and REQUIRED_PARAMS.issubset(parameters.keys())


def invalid_http_response(parameters) -> object:
    return {
        "statusCode": 400,
        "body": f"Invalid request parameters {str(parameters)}"
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
