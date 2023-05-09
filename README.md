# airline_services

A collection of sample cloud-native serverless micro-services inspired by the airline industry. This project is intended to (eventually) illustrate best practices for a set of services in an enterprise environment from architecture planning through implementation and deployment.


TODO:
- Flight Details
  - Convert into a module with examples
  - Move lambda logic to a separate repositories
  - Switch "update flights" to standard lambda module
    - https://registry.terraform.io/modules/terraform-aws-modules/lambda/aws/latest
- GitOps & CI/CD
  - Move modules into a separate repository
  - Setup "main" repository
    - top level terraform
    - tfvars for each environment
  - Setup Jenkins using Terraform
  - Create separate pipelines: DEV/QA/PROD
  - Trigger pipelines from Git branches (preferrably tags)
- Route 53 DNS
- Add Other Services as Modules
  - Messages
  - Profiles
- Convert all SQS queues to Kafka
- Condider rewriting lambdas using Golang
