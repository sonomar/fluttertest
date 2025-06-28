# deins_app lambda functions

This section deals with how to create a lambda function for the backend

## Steps

- [The link to follow steps to create and deploy the lambda functions](https://docs.aws.amazon.com/lambda/latest/dg/python-package.html)

- [Secrets](https://eu-central-1.console.aws.amazon.com/secretsmanager/listsecrets?region=eu-central-1)
- [RDS database](https://eu-central-1.console.aws.amazon.com/rds/home?region=eu-central-1#databases:)
- [SecretManagerReadAndWrite](https://us-east-1.console.aws.amazon.com/iam/home?region=eu-central-1#/policies/details/arn%3Aaws%3Aiam%3A%3Aaws%3Apolicy%2FSecretsManagerReadWrite?section=entities_attached)
- [Video link for Lambda function](https://www.youtube.com/watch?v=3Ar1ABlD_Vs&t=99s&ab_channel=TinyTechnicalTutorials)

aws cognito-idp initiate-auth \
 --client-id 3habrhuviqskit3ma595m5dp0b \
 --auth-flow USER_PASSWORD_AUTH \
 --auth-parameters USERNAME=koolankit3@gmail.com,PASSWORD=123456\
 --region eu-central-1
