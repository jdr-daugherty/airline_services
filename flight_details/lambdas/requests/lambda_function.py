import boto3
from botocore.exceptions import BotoCoreError, ClientError
import json
import logging
import os
import signal
import sys

ARRIVAL_PARAMS = {'tail', 'arrival_code', 'arrival_date'}
DEPARTURE_PARAMS = {'departure_code', 'flight_number', 'departure_date'}

LOGGER = logging.getLogger()
LOGGER.setLevel(logging.INFO)

ARRIVAL_TABLE_NAME = os.getenv('ARRIVAL_TABLE')
DEPARTURE_TABLE_NAME = os.getenv('DEPARTURE_TABLE')

if ARRIVAL_TABLE_NAME is None or DEPARTURE_TABLE_NAME is None:
    raise RuntimeError("Table name(s) not defined.")

try:
    CLIENT = boto3.resource('dynamodb')
    ARRIVAL_TABLE = CLIENT.Table(ARRIVAL_TABLE_NAME)
    DEPARTURE_TABLE = CLIENT.Table(DEPARTURE_TABLE_NAME)
except Exception as ex:
    LOGGER.exception("Failed to initialize lambda")
    raise ex


def lambda_handler(event, context) -> object:
    if is_invalid_request(event):
        return to_invalid_response(None)

    request = event['pathParameters']['request']
    query_params = event['queryStringParameters']

    if 'by-arrival' == request:
        return by_arrival(query_params)
    elif 'by-departure' == request:
        return by_departure(query_params)
    else:
        return to_invalid_response(request)


def by_arrival(query_params: dict[str, str]) -> object:
    if not valid_query_params(query_params, ARRIVAL_PARAMS):
        return to_invalid_response(f"by-arrival parameters: {str(query_params)}")

    return get_from_table(ARRIVAL_TABLE, to_arrival_key(query_params))


def by_departure(query_params: dict[str, str]) -> object:
    if not valid_query_params(query_params, DEPARTURE_PARAMS):
        return to_invalid_response(f"by-departure parameters: {str(query_params)}")

    return get_from_table(DEPARTURE_TABLE, to_departure_key(query_params))


def valid_query_params(parameters: dict[str, str], required: set[str]) -> bool:
    return parameters is not None and required.issubset(parameters.keys())


def to_invalid_response(message: str or None) -> object:
    LOGGER.info("Invalid request: %s", message)
    return http_response(400, f"Invalid request: {message}")


def to_arrival_key(params: dict[str, str]) -> dict[str, str]:
    """ Creates a hash key for the by-arrival table.

    Keyword arguments:
        params -- the query parameters
    """
    return {
        'key': f"{params['tail']}_{params['arrival_code']}_{params['arrival_date']}"
    }


def to_departure_key(params: dict[str, str]) -> dict[str, str]:
    """ Creates a hash key for the by-departure table.

    Keyword arguments:
        params -- the query parameters
    """
    return {
        'key': f"{params['departure_code']}_{params['flight_number']}_{params['departure_date']}"
    }


def get_from_table(table, key: dict[str, str]) -> object:
    try:
        return dynamodb_to_http(key, table.get_item(Key=key))
    except BotoCoreError or ClientError as error:
        LOGGER.exception("Failed to get flight from %s: %s", table.table_name, key)
        raise error


def dynamodb_to_http(key: dict[str, str], dynamodb_response: dict[str, object]) -> object:
    if 'Item' in dynamodb_response:
        LOGGER.debug("Returning flight: %s", key)
        return http_response(200, json.dumps(dynamodb_response['Item']))

    LOGGER.info("Flight not found: %s", key)
    return http_response(404, f"Flight not found in table {str(key)}")


def http_response(status_code: int, body: str) -> object:
    return {"statusCode": status_code, "body": body}


def is_invalid_request(event):
    return (event is None or
            event['queryStringParameters'] is None or
            event['pathParameters'] is None or
            event['pathParameters']['request'] is None)


def exit_gracefully(signum: int, frame: object) -> None:
    try:
        CLIENT.close()
    finally:
        sys.exit(0)


signal.signal(signal.SIGTERM, exit_gracefully)
