import boto3
from botocore.exceptions import BotoCoreError, ClientError
import json
import logging
import os
import signal
import sys


REQUIRED_PARAMS = {'departure_code', 'flight_number', 'departure_date'}

try:
    LOGGER = logging.getLogger()
    CLIENT = boto3.resource('dynamodb')
    TABLE = CLIENT.Table(os.getenv('DYNAMODB_TABLE'))
except Exception as ex:
    LOGGER.exception("Failed to initialize lambda")
    raise ex


# Lambda Test Event
# {
#   "pathParameters": {
#       "departure_code": "MEM",
#       "flight_number": "5420",
#       "departure_date": "2022-05-18"
#   }
# }
def lambda_handler(event, context):
    parameters = event['pathParameters']

    if not valid_parameters(parameters):
        LOGGER.info("Invalid parameters: %s", str(parameters))
        return invalid_http_response()

    key = to_key(parameters)

    return to_http_response(key, request_item(key))


def request_item(key: dict[str, str]) -> dict[str, object]:
    try:
        return TABLE.get_item(Key=key)
    except BotoCoreError or ClientError as error:
        LOGGER.exception("Failed to retrieve flight details from DynamoDB: %s", key)
        raise error


def valid_parameters(parameters: dict[str, str]) -> bool:
    return parameters is not None and REQUIRED_PARAMS.issubset(parameters.keys())


def invalid_http_response() -> object:
    return {
        "statusCode": 400,
        "body": "Invalid request parameters"
    }


def to_http_response(key: dict[str, str], dynamodb_response: dict[str, object]) -> object:
    if 'Item' in dynamodb_response:
        LOGGER.debug("Returning flight details for: %s", key)
        return {
            "statusCode": 200,
            "body": json.dumps(dynamodb_response['Item'])
        }
    else:
        LOGGER.debug("Flight details not found for: %s", key)
        return {
            "statusCode": 404,
            "body": f"Item not found in table {str(key)}"
        }


def to_key(parameters: dict[str, str]) -> dict[str, str]:
    # [Departure Code]_[Flight Number]_[Planned Departure Date Herb
    dep_code = parameters['departure_code']
    flight_number = parameters['flight_number']
    dep_date = parameters['departure_date']

    return {
        'key': f'{dep_code}_{flight_number}_{dep_date}'
    }


def exit_gracefully(signum: int, frame: object) -> None:
    try:
        CLIENT.close()
    finally:
        sys.exit(0)


signal.signal(signal.SIGTERM, exit_gracefully)
