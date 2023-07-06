# airline_services

A collection of sample cloud-native serverless micro-services inspired by the airline industry. This project is intended to (eventually) illustrate best practices for a set of services in an enterprise environment from architecture planning through implementation and deployment.


## To-Do List
- Add Other Services
  - Messages
  - Profiles
- Flight Details
  - Convert into a module with examples
  - Move lambda logic to a separate repositories
  - Convert SQS queue to Kinesis or Kafka
- Crew Profile Service
  - Add "by name" request using Fuzzy String Matching: https://github.com/seatgeek/thefuzz
- GitOps & CI/CD
  - Setup pipeline infrastructure (Jenkins/CodeDeploy) using Separate Terraform
  - Create separate environments: DEV/QA/PROD
    - Setup tfvars for each environment
    - Separate pipelines
    - Trigger pipelines from Git branches (preferrably tags)
  - Move modules into a separate repository
- Route 53 DNS
- VPC, etc.
- Authentication
  - OAuth
  - Lambda Authorizer
- Rewrite lambdas in Golang
