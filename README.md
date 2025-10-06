# Tech Challenge API Gateway

This project sets up an AWS API Gateway using Terraform to manage various RESTful APIs. The APIs are defined in the `refs` directory, and the infrastructure is managed through Terraform modules.

## Project Structure

- **modules/api_gateway/**: Contains the Terraform module for the API Gateway.
  - **main.tf**: Main configuration for the API Gateway, defining resources and endpoints.
  - **variables.tf**: Input variables for the API Gateway module.
  - **outputs.tf**: Outputs from the API Gateway module.

- **refs/**: Contains the Java files for the REST APIs.
  - **CategoryRestController.java**: API for category operations.
  - **CustomerRestController.java**: API for customer operations.
  - **HealthCheckRestController.java**: API for health check operations.
  - **OrderRestController.java**: API for order operations.
  - **PaymentRestController.java**: API for payment operations.
  - **ProductRestController.java**: API for product operations.
  - **Tech_Challenge_API.postman_collection.json**: Postman collection for testing the APIs.
  - **WebhookRestController.java**: API for webhook operations.

- **.github/workflows/**: Contains the GitHub Actions workflow for automated deployment.
  - **deploy.yml**: Workflow configuration for deploying the API Gateway using Terraform.

- **main.tf**: Entry point for the Terraform configuration, calling the API Gateway module.

- **variables.tf**: Input variables for the main Terraform configuration.

- **outputs.tf**: Outputs from the main Terraform configuration.

- **provider.tf**: Configuration for the AWS provider.

## Setup Instructions

1. **Clone the Repository**: Clone this repository to your local machine.
   
   ```bash
   git clone <repository-url>
   cd tech-challenge-terraform-api-gateway
   ```

2. **Configure AWS Credentials**: Ensure your AWS credentials are set up in GitHub Secrets for the deployment workflow.

3. **Initialize Terraform**: Run the following command to initialize Terraform.

   ```bash
   terraform init
   ```

4. **Plan the Deployment**: Review the planned actions before applying.

   ```bash
   terraform plan
   ```

5. **Apply the Configuration**: Deploy the API Gateway.

   ```bash
   terraform apply
   ```

## Usage

After deployment, the API Gateway will be available at the URL provided in the outputs. You can use the Postman collection in `refs/Tech_Challenge_API.postman_collection.json` to test the endpoints.

## Contributing

Feel free to submit issues or pull requests for improvements or bug fixes.
