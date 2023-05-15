resource "time_offset" "expiration_date" {
  offset_days = 90
}

resource "aws_dynamodb_table_item" "departures_test_row" {
  count      = length(regexall(".*-dev-.*", local.prefix)) > 0 ? 1 : 0
  table_name = module.departures_table.name
  hash_key   = module.departures_table.hash_key

  item = <<ITEM
{
  "key": {"S": "MEM_5420_2022-05-18"},

  "createdBy": {"S": ""},
  "createdTime": {"S": "2022-04-18T18:54:21.762Z"},

  "number": {"S": "5420"},
  "tailNumber": {"S": "N413WN"},

  "departureDate": {"S": "2022-05-03"},

  "departureStationCode": {"S": "MEM"},
  "departureStationTimeZone": {"S": "America/Chicago"},
  "originalArrivalTime": {"S": "2022-05-18T20:29:40.131Z"},
  "currentDepartureTime": {"S": "2022-05-03T18:54:21.762Z"},
  "outboundStatus": {"S": "On Time"},
  "departureGate": {"S": "B3"},

  "arrivalStationCode": {"S": "DAL"},
  "arrivalStationTimeZone": {"S": "America/Los_Angeles"},
  "originalArrivalTime": {"S": "2022-05-18T20:29:40.131Z"},
  "currentArrivalTime": {"S": "2022-05-18T20:43:29.487Z"},
  "inboundStatus": {"S": "Delayed"},
  "arrivalGate": {"S": "C17"},

  "lastModifiedBy": {"S": ""},
  "lastModifiedTime": {"S": "2022-04-22T15:24:29.882Z"},

  "expiration_time": {"S": "${time_offset.expiration_date.unix}"}
}
ITEM
}

resource "aws_dynamodb_table_item" "arrivals_test_row" {
  count      = length(regexall(".*-dev-.*", local.prefix)) > 0 ? 1 : 0
  table_name = module.arrivals_table.name
  hash_key   = module.arrivals_table.hash_key

  item = <<ITEM
{
  "key": {"S": "N413WN_DAL_2022-05-18"},

  "createdBy": {"S": ""},
  "createdTime": {"S": "2022-04-18T18:54:21.762Z"},

  "number": {"S": "5420"},
  "tailNumber": {"S": "N413WN"},

  "departureDate": {"S": "2022-05-03"},

  "departureStationCode": {"S": "MEM"},
  "departureStationTimeZone": {"S": "America/Chicago"},
  "originalArrivalTime": {"S": "2022-05-18T20:29:40.131Z"},
  "currentDepartureTime": {"S": "2022-05-03T18:54:21.762Z"},
  "outboundStatus": {"S": "On Time"},
  "departureGate": {"S": "B3"},

  "arrivalStationCode": {"S": "DAL"},
  "arrivalStationTimeZone": {"S": "America/Los_Angeles"},
  "originalArrivalTime": {"S": "2022-05-18T20:29:40.131Z"},
  "currentArrivalTime": {"S": "2022-05-18T20:43:29.487Z"},
  "inboundStatus": {"S": "Delayed"},
  "arrivalGate": {"S": "C17"},

  "lastModifiedBy": {"S": ""},
  "lastModifiedTime": {"S": "2022-04-22T15:24:29.882Z"},

  "expiration_time": {"S": "${time_offset.expiration_date.unix}"}
}
ITEM
}