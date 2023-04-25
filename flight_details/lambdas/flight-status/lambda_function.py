import boto3
import datetime
import logging
import os
import json

client = boto3.resource('dynamodb')
table = client.Table(os.getenv('TABLE'))


def lambda_handler(event, context):
    if not valid_parameters(event['pathParameters']):
        return {
            "statusCode": 400
        }

    result = table.get_item(to_key(event['pathParameters']))

    if 'Item' not in result:
        return {
            "statusCode": 404,
            "body": f"Item not found in table {str(event['pathParameters'])}"
        }

    return {
        "statusCode": 200,
        "body": json.dumps(result['Item'])
    }


def valid_parameters(parameters: dict[str, str]) -> bool:
    for r in ['departure_location', 'flight_number', 'departure_date']:
        if r not in parameters:
            return False

    return True


def to_key(parameters: dict[str, str]) -> dict[str, str]:
    # [Departure Code]_[Flight Number]_[Planned Departure Date Herb
    dep_code = parameters['departure_location']
    flight_number = parameters['flight_number']
    dep_date = parameters['departure_date']

    return {
        'key': f'{dep_code}_{flight_number}_{dep_date}'
    }
