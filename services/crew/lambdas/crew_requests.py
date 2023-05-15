import boto3
from botocore.exceptions import BotoCoreError, ClientError
import json
import logging
import os
import signal
import sys

LOGGER = logging.getLogger()
LOGGER.setLevel(logging.INFO)

TABLE_NAME = os.getenv('TABLE_NAME')

if TABLE_NAME is None :
    raise RuntimeError("Table name not defined.")

try:
    CLIENT = boto3.resource('dynamodb')
    TABLE = CLIENT.Table(TABLE_NAME)
except Exception as ex:
    LOGGER.exception("Failed to initialize lambda")
    raise ex


def lambda_handler(event, context) -> object:
    if is_invalid_request(event):
        return to_invalid_response(None)

    request = event['pathParameters']['request']
    query_params = event['queryStringParameters']

    if 'by-eid' == request:
        return by_eid(query_params)
    else:
        return to_invalid_response(request)


def by_eid(query_params: dict[str, str]) -> object:
    if not valid_query_params(query_params, {"eid"}):
        return to_invalid_response(f"by-eid parameters: {str(query_params)}")

    return get_from_table(TABLE, {'eid': query_params['eid']})


def valid_query_params(parameters: dict[str, str], required: set[str]) -> bool:
    return parameters is not None and required.issubset(parameters.keys())


def to_invalid_response(message: str or None) -> object:
    LOGGER.info("Invalid request: %s", message)
    return http_response(400, f"Invalid request: {message}")


def get_from_table(table, key: dict[str, str]) -> object:
    try:
        return dynamodb_to_http(key, table.get_item(Key=key))
    except BotoCoreError or ClientError as error:
        LOGGER.exception("Failed to get crew from %s: %s", table.table_name, key)
        raise error


def dynamodb_to_http(key: dict[str, str], dynamodb_response: dict[str, object]) -> object:
    if 'Item' in dynamodb_response:
        LOGGER.debug("Returning crew: %s", key)
        return http_response(200, json.dumps(dynamodb_response['Item']))

    LOGGER.info("Crew not found: %s", key)
    return http_response(404, f"Crew not found in table {str(key)}")


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
