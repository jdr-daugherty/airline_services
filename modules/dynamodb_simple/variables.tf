variable "prefix" {
  type = string
  description = "The prefix to apply to the name of the table and other infrastructure (e.g. airline-dev-blue)."
}

variable "table_name" {
  description = "The name of the table (e.g. by-departure)"
  type = string
}