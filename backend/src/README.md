database
alembic revision -m "create initial tables" --autogenerate
alembic upgrade head

app run locally
uvicorn main:app --reload     


python.analysis.typeCheckingMode


install AWS CLI
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg AWSCLIV2.pkg -target /

Please run 'aws configure' and ensure your IAM user/role has necessary permissions (e.g., for STS, Lambda).

policies that AWS admin role should have
secretsmanager:GetSecretValue
AWSLambdaBasicExecutionRole
Cognito-authenticated-1732572902506
