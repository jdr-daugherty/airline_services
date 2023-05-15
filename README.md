# airline_services

A collection of sample cloud-native serverless micro-services inspired by the airline industry. This project is intended to (eventually) illustrate best practices for a set of services in an enterprise environment from architecture planning through implementation and deployment.


## To-Do List
- Add Other Services
  - Messages
  - Profiles
- Flight Details
  - Convert into a module with examples
  - Move lambda logic to a separate repositories
  - Convert SQS queue to Kinesis
- GitOps & CI/CD
  - Move modules into a separate repository
  - Setup "main" repository
    - top level terraform
    - tfvars for each environment
  - Setup Jenkins using Terraform
  - Create separate pipelines: DEV/QA/PROD
  - Trigger pipelines from Git branches (preferrably tags)
- Route 53 DNS
- VPC, etc.
- Authentication
  - OAuth
  - Lambda Authorizer
- Rewrite lambdas in Golang
