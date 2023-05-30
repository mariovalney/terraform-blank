# TERRAFORM BLANK

Example of project with Terraform IaaS.

## Terraform

STILL IN DEVELOPMENT

First time you'll need to authenticate with AWS.
Create a administrator user in IAM if you do not have one.

`aws configure --profile <STACK>`


### Configuring

Set your project profile/variables in `stacks/example/terraform.tfvars`.

### Running

Go to `terraform/` to run Terraform.

Every command should be inside container: `docker-compose run <STACK> <COMMAND>`.

Stacks:

* `example`

### Environment / Workspace

Make sure you are in the workspace you want:

`docker-compose run <STACK> workspace select <ENVIRONMENT>`

First time? You can create a new on:

`docker-compose run <STACK> workspace new <ENVIRONMENT>`

And run INIT:

`docker-compose run <STACK> init`

Environments:

* `production`
