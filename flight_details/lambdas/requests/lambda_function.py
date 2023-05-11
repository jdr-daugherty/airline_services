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
try:
    CLIENT = boto3.resource('dynamodb')
    ARRIVAL_TABLE = CLIENT.Table(os.getenv('ARRIVAL_TABLE'))
    DEPARTURE_TABLE = CLIENT.Table(os.getenv('DEPARTURE_TABLE'))
except Exception as ex:
    LOGGER.exception("Failed to initialize lambda")
    raise ex


def lambda_handler(event, context) -> object:
    path_params = event['pathParameters']
    query_params = event['queryStringParameters']

    if path_params is None or query_params is None:
        LOGGER.info("Invalid parameters: %s", json.dumps(event))
        return invalid_http_response(None)

    request = path_params['request']

    if 'by-arrival' == request:
        return by_arrival(query_params)
    elif 'by-departure' == request:
        return by_departure(query_params)
    else:
        return invalid_http_response(path_params)


def by_arrival(query_params: dict[str, str]) -> object:
    if not valid_parameters(query_params, ARRIVAL_PARAMS):
        LOGGER.info("Invalid parameters: %s", str(query_params))
        return invalid_http_response(query_params)

    key = to_arrival_key(query_params)
    return to_http_response(key, get_from_table(ARRIVAL_TABLE, key))


def by_departure(query_params: dict[str, str]) -> object:
    if not valid_parameters(query_params, DEPARTURE_PARAMS):
        LOGGER.info("Invalid parameters: %s", str(query_params))
        return invalid_http_response(query_params)

    key = to_departure_key(query_params)
    return to_http_response(key, get_from_table(DEPARTURE_TABLE, key))


def valid_parameters(parameters: dict[str, str], required: set[str]) -> bool:
    return parameters is not None and required.issubset(parameters.keys())


def invalid_http_response(parameters: dict[str, str] or None) -> object:
    return {
        "statusCode": 400,
        "body": f"Invalid request parameters {str(parameters)}"
    }


def to_arrival_key(parameters: dict[str, str]) -> dict[str, str]:
    tail = parameters['tail']
    arrival_code = parameters['arrival_code']
    arrival_date = parameters['arrival_date']

    return {
        'key': f'{tail}_{arrival_code}_{arrival_date}'
    }


def to_departure_key(parameters: dict[str, str]) -> dict[str, str]:
    # [Departure Code]_[Flight Number]_[Planned Departure Date Herb
    dep_code = parameters['departure_code']
    flight_number = parameters['flight_number']
    dep_date = parameters['departure_date']

    return {
        'key': f'{dep_code}_{flight_number}_{dep_date}'
    }


def get_from_table(table, key: dict[str, str]) -> dict[str, object]:
    try:
        return table.get_item(Key=key)
    except BotoCoreError or ClientError as error:
        LOGGER.exception("Failed to get flight from %s: %s", table.table_name, key)
        raise error


def to_http_response(key: dict[str, str], dynamodb_response: dict[str, object]) -> object:
    if 'Item' in dynamodb_response:
        LOGGER.debug("Returning flight for: %s", key)
        return {
            "statusCode": 200,
            "body": json.dumps(dynamodb_response['Item'])
        }
    else:
        LOGGER.debug("Inbound flight for: %s", key)
        return {
            "statusCode": 404,
            "body": f"Flight not found in table {str(key)}"
        }


def exit_gracefully(signum: int, frame: object) -> None:
    try:
        CLIENT.close()
    finally:
        sys.exit(0)


signal.signal(signal.SIGTERM, exit_gracefully)
