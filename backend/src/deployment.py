import os
import subprocess
import zipfile
import json # For parsing AWS CLI output
import shutil # For directory cleanup

def read_dependencies_from_file(package_file_path):
    """Reads dependencies from a file and returns a list of them, skipping comments."""
    if not os.path.exists(package_file_path):
        print(f"Warning: Dependency file '{package_file_path}' not found. Assuming no dependencies.")
        return []
    with open(package_file_path, 'r') as f:
        return [line.strip() for line in f.readlines() if line.strip() and not line.startswith('#')]

def add_folder_to_zip(zipf, folder_path, base_folder_to_strip):
    """
    Recursively adds a folder and its contents to a ZIP file.
    'base_folder_to_strip' is the path part to remove to get the desired path in the zip.
    """
    for root, dirs, files in os.walk(folder_path):
        dirs[:] = [d for d in dirs if d != '__pycache__']
        files = [f for f in files if not f.endswith('.pyc')]

        for file in files:
            full_path = os.path.join(root, file)
            archive_name = os.path.relpath(full_path, base_folder_to_strip)
            zipf.write(full_path, archive_name)

def check_aws_cli():
    """Checks if AWS CLI is installed and minimally configured."""
    try:
        subprocess.run(['aws', '--version'], check=True, capture_output=True, text=True)
        identity_check = subprocess.run(['aws', 'sts', 'get-caller-identity'], check=True, capture_output=True, text=True)
        try:
            caller_identity_arn = json.loads(identity_check.stdout).get('Arn')
            print(f"AWS CLI found and configured. Caller Identity ARN: {caller_identity_arn}")
        except json.JSONDecodeError:
            print(f"AWS CLI found and configured. Could not parse 'get-caller-identity' JSON. Raw: {identity_check.stdout.strip()}")
        return True
    except FileNotFoundError:
        print("ERROR: AWS CLI not found. Please install it and ensure it's in your PATH.")
        print("See: https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html")
        return False
    except subprocess.CalledProcessError as e:
        print("ERROR: AWS CLI is present but not configured correctly or lacks permissions.")
        print(f"Command failed: {' '.join(e.cmd)}")
        stderr_output = e.stderr.strip() if e.stderr else "No stderr output"
        print(f"Error: {stderr_output}")
        print("Please run 'aws configure' and ensure your IAM user/role has necessary permissions (e.g., for STS, Lambda).")
        return False

def lambda_exists(function_name, region=None):
    """Checks if an AWS Lambda function already exists."""
    cmd = ['aws', 'lambda', 'get-function', '--function-name', function_name]
    if region:
        cmd.extend(['--region', region])
    try:
        subprocess.run(cmd, check=True, capture_output=True, text=True)
        print(f"Lambda function '{function_name}' found.")
        return True
    except subprocess.CalledProcessError as e:
        if "ResourceNotFoundException" in e.stderr:
            print(f"Lambda function '{function_name}' not found.")
            return False
        else:
            print(f"Error checking if Lambda function '{function_name}' exists: {e.stderr}")
            raise

def upload_to_s3(zip_file_path, bucket_name, s3_key, region=None):
    """Uploads the deployment package to S3."""
    print(f"Uploading '{zip_file_path}' to s3://{bucket_name}/{s3_key}...")
    cmd = ['aws', 's3', 'cp', zip_file_path, f's3://{bucket_name}/{s3_key}']
    if region:
        cmd.extend(['--region', region])
    try:
        subprocess.run(cmd, check=True, capture_output=True, text=True)
        print("Successfully uploaded to S3.")
        return True
    except subprocess.CalledProcessError as e:
        print(f"ERROR: Failed to upload to S3.")
        print(f"Command: {' '.join(e.cmd)}")
        print(f"Stderr: {e.stderr}")
        return False

def deploy_lambda_function(zip_file_path, function_name, handler, runtime, role_arn,
                           region=None, s3_bucket=None, s3_key=None,
                           timeout=30, memory_size=128, environment_variables=None, publish=True):
    """
    Deploys the Lambda function to AWS.
    Creates the function if it doesn't exist, otherwise updates its code and configuration.
    Returns True on success, False on failure.
    """
    print(f"\nAttempting to deploy Lambda function: {function_name}")
    aws_command_base = ['aws', 'lambda']
    if region:
        aws_command_base.extend(['--region', region])

    try:
        exists = lambda_exists(function_name, region)
        code_location_args = []
        if s3_bucket and s3_key:
            print(f"Using S3 object for deployment: s3://{s3_bucket}/{s3_key}")
            code_location_args = ['--code', f'S3Bucket={s3_bucket},S3Key={s3_key}']
        else:
            print(f"Using local zip file for deployment: {zip_file_path}")
            code_location_args = ['--zip-file', f'fileb://{zip_file_path}']

        if exists:
            print(f"Updating existing Lambda function '{function_name}'...")
            cmd_update_code = aws_command_base + ['update-function-code', '--function-name', function_name] + code_location_args
            if publish: cmd_update_code.append('--publish')
            print(f"Executing: {' '.join(cmd_update_code[:5])} ... (code args hidden for brevity)")
            result_code = subprocess.run(cmd_update_code, check=True, capture_output=True, text=True)
            print(f"Function code updated. Version: {json.loads(result_code.stdout).get('Version', 'N/A')}")

            print(f"Waiting for function '{function_name}' code update to complete...")
            cmd_wait_code_update = aws_command_base + ['wait', 'function-updated', '--function-name', function_name]
            subprocess.run(cmd_wait_code_update, check=True, capture_output=True, text=True)
            print(f"Function '{function_name}' is now updated and ready for configuration changes.")

            print("Updating function configuration...")
            cmd_update_config = aws_command_base + [
                'update-function-configuration', '--function-name', function_name,
                '--runtime', runtime, '--role', role_arn, '--handler', handler,
                '--timeout', str(timeout), '--memory-size', str(memory_size)
            ]
            if environment_variables:
                env_vars_string = ",".join([f"{k}={v}" for k, v in environment_variables.items()])
                cmd_update_config.extend(['--environment', f"Variables={{{env_vars_string}}}"])
            print(f"Executing: {' '.join(cmd_update_config[:5])} ...")
            subprocess.run(cmd_update_config, check=True, capture_output=True, text=True)
            print("Function configuration updated successfully.")
        else:
            print(f"Creating new Lambda function '{function_name}'...")
            cmd_create = aws_command_base + [
                'create-function', '--function-name', function_name,
                '--runtime', runtime, '--role', role_arn, '--handler', handler,
                '--timeout', str(timeout), '--memory-size', str(memory_size)
            ] + code_location_args
            if environment_variables:
                env_vars_string = ",".join([f"{k}={v}" for k, v in environment_variables.items()])
                cmd_create.extend(['--environment', f"Variables={{{env_vars_string}}}"])
            if publish: cmd_create.append('--publish')
            print(f"Executing: {' '.join(cmd_create[:5])} ... (code args hidden for brevity)")
            result_create = subprocess.run(cmd_create, check=True, capture_output=True, text=True)
            created_function_arn = json.loads(result_create.stdout)['FunctionArn']
            print(f"Successfully created Lambda function. ARN: {created_function_arn}")

            print(f"Waiting for new function '{function_name}' to become active...")
            cmd_wait_creation = aws_command_base + ['wait', 'function-active-v2', '--function-name', function_name]
            subprocess.run(cmd_wait_creation, check=True, capture_output=True, text=True)
            print(f"New function '{function_name}' is active.")
        return True
    except subprocess.CalledProcessError as e:
        print(f"ERROR during AWS CLI command execution for function '{function_name}':")
        print(f"Command: {' '.join(e.cmd)}")
        print(f"Return code: {e.returncode}")
        stderr_output = e.stderr.strip() if e.stderr else "No stderr output"
        stdout_output = e.stdout.strip() if e.stdout else "No stdout output"
        print(f"Stderr: {stderr_output}")
        if stdout_output: print(f"Stdout: {stdout_output}")
        return False
    except Exception as e:
        print(f"An unexpected error occurred during deployment: {e}")
        return False

def create_and_deploy_lambda(
    lambda_handler_file,
    dependencies_file,
    aws_lambda_function_name,
    aws_lambda_handler,
    aws_lambda_runtime,
    aws_iam_role_arn,
    folders_to_include=None,
    aws_deployment_region=None,
    aws_s3_bucket_for_upload=None,
    lambda_timeout=60,
    lambda_memory_size=256,
    lambda_env_variables=None,
    publish_new_version=True,
    perform_deployment=True # New parameter
):
    """
    Packages the Lambda function and optionally deploys it.
    Returns: tuple (zip_file_path_or_none, deployment_status_or_none)
             deployment_status is True for success, False for failure, None if not attempted.
    """
    if perform_deployment and not check_aws_cli(): # Check CLI early if deployment is intended
        print("Aborting due to AWS CLI issues.")
        return None, False # Packaging not attempted, deployment failed implicitly

    project_dir = os.getcwd()
    package_build_dir_name = 'lambda_package_build_temp'
    package_build_dir = os.path.join(project_dir, package_build_dir_name)
    zip_file_path = None # Initialize

    try:
        if os.path.exists(package_build_dir):
            print(f"Removing existing temporary package build directory: {package_build_dir}")
            shutil.rmtree(package_build_dir)
        os.makedirs(package_build_dir)
        print(f"Created temporary package build directory: {package_build_dir}")

        dependencies = read_dependencies_from_file(dependencies_file)
        if dependencies:
            print("\nInstalling dependencies...")
            runtime_version_for_pip = aws_lambda_runtime.replace('python', '') if 'python' in aws_lambda_runtime else '3.9'
            for dep in dependencies:
                print(f"Installing: {dep} into {package_build_dir}")
                pip_command = [
                    'pip', 'install',
                    '--target', package_build_dir,
                    '--platform', 'manylinux2014_x86_64',
                    '--implementation', 'cp',
                    '--python-version', runtime_version_for_pip,
                    '--only-binary', ':all:',
                    '--upgrade',
                    dep
                ]
                subprocess.run(pip_command, check=True, capture_output=True, text=True)
        else:
            print("\nNo dependencies found in dependencies file or file not present.")

        zip_file_name = f"{aws_lambda_function_name}_deployment_package.zip"
        zip_file_path = os.path.join(project_dir, zip_file_name)

        print(f"\nCreating ZIP file: {zip_file_path}")
        with zipfile.ZipFile(zip_file_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
            if os.path.exists(package_build_dir) and os.listdir(package_build_dir):
                print(f"Adding dependencies from '{package_build_dir}' to ZIP.")
                add_folder_to_zip(zipf, package_build_dir, package_build_dir)
            
            if os.path.exists(lambda_handler_file):
                print(f"Adding Lambda handler '{lambda_handler_file}' to ZIP as '{os.path.basename(lambda_handler_file)}'.")
                zipf.write(lambda_handler_file, os.path.basename(lambda_handler_file))
            else:
                print(f"ERROR: Lambda handler file '{lambda_handler_file}' not found!")
                raise FileNotFoundError(f"Lambda handler file {lambda_handler_file} not found.")

            if folders_to_include:
                for folder_name in folders_to_include:
                    folder_path = os.path.join(project_dir, folder_name)
                    if os.path.exists(folder_path) and os.path.isdir(folder_path):
                        print(f"Adding folder '{folder_name}' to the ZIP file.")
                        add_folder_to_zip(zipf, folder_path, project_dir)
                    else:
                        print(f"Warning: Folder '{folder_name}' not found at '{folder_path}' or is not a directory, skipping.")
        
        file_size_kb = os.path.getsize(zip_file_path) / 1024
        print(f"Deployment package created: {zip_file_path} (Size: {file_size_kb:.2f} KB)")

    except Exception as e:
        print(f"ERROR during packaging: {e}")
        if package_build_dir and os.path.exists(package_build_dir): # Clean up build dir on packaging error
            shutil.rmtree(package_build_dir)
        if zip_file_path and os.path.exists(zip_file_path): # Clean up partial zip on packaging error
            os.remove(zip_file_path)
        return None, False if perform_deployment else None # (zip_path, deploy_status)
    finally:
        if package_build_dir and os.path.exists(package_build_dir): # Ensure cleanup
            print(f"Cleaning up temporary package build directory: {package_build_dir}")
            shutil.rmtree(package_build_dir)

    # --- Deployment Step (Conditional) ---
    if not perform_deployment:
        print("\nPackaging complete. Deployment skipped as per user request.")
        return zip_file_path, None # (zip_path, deploy_status=None)

    print("\nProceeding with deployment...")
    s3_uploaded_key = None
    if aws_s3_bucket_for_upload:
        s3_uploaded_key = f"lambda-deployments/{aws_lambda_function_name}/{os.path.basename(zip_file_path)}"
        print(f"\nS3 deployment bucket specified: {aws_s3_bucket_for_upload}")
        if not upload_to_s3(zip_file_path, aws_s3_bucket_for_upload, s3_uploaded_key, aws_deployment_region):
            print("Failed to upload to S3. Deployment aborted.")
            return zip_file_path, False # (zip_path, deploy_status=False)
    else:
        print("\nNo S3 deployment bucket specified, proceeding with direct ZIP upload.")
    
    deploy_success = deploy_lambda_function(
        zip_file_path=zip_file_path,
        function_name=aws_lambda_function_name,
        handler=aws_lambda_handler,
        runtime=aws_lambda_runtime,
        role_arn=aws_iam_role_arn,
        region=aws_deployment_region,
        s3_bucket=aws_s3_bucket_for_upload if s3_uploaded_key else None,
        s3_key=s3_uploaded_key if s3_uploaded_key else None,
        timeout=lambda_timeout,
        memory_size=lambda_memory_size,
        environment_variables=lambda_env_variables,
        publish=publish_new_version
    )

    if deploy_success:
        print(f"\nLambda function '{aws_lambda_function_name}' deployed successfully.")
    else:
        print(f"\nLambda function '{aws_lambda_function_name}' deployment FAILED.")
    
    return zip_file_path, deploy_success # (zip_path, deploy_status)

# ==============================================================================
# Example Usage: Configure and run this section
# ==============================================================================
if __name__ == "__main__":
    print("Starting Lambda Packaging and Deployment Script")
    print("==============================================")

    # --- Core Configuration - MODIFY THESE VALUES ---
    LAMBDA_HANDLER_FILE = 'lambda_function.py'
    DEPENDENCIES_FILE = 'package.txt'

    AWS_FUNCTION_NAME = 'DeinsBackend_Prod'
    AWS_HANDLER_NAME = 'lambda_function.lambda_handler'
    # IMPORTANT: Change to a supported runtime if python3.13 is not yet available in your region
    AWS_RUNTIME = 'python3.13' # Changed from python3.13 as a safer default
    # IMPORTANT: Ensure this role has the correct trust policy for 'lambda.amazonaws.com'
    AWS_IAM_ROLE_ARN = 'arn:aws:iam::557690594992:role/service-role/Admin'
    
    AWS_REGION = 'eu-central-1'
    AWS_S3_DEPLOYMENT_BUCKET = None # Set to bucket name for S3 deployment, None for direct upload

    LAMBDA_TIMEOUT_SECONDS = 45
    LAMBDA_MEMORY_MB = 192
    LAMBDA_ENVIRONMENT_VARIABLES = {
        "ENV": "production",
        "EXAMPLE_VAR": "HelloFromLambdaEnv",
        "secret_key": "arn:aws:secretsmanager:eu-central-1:557690594992:secret:Deins_Secret_Prod-uhtY6Y"
    }
    FOLDERS_TO_PACKAGE = ['api', 'tools', 'database']

    # --- Sanity Checks & Dummy File Creation for Testing (same as before) ---
    current_dir = os.getcwd()
    if not os.path.exists(LAMBDA_HANDLER_FILE):
        print(f"Creating dummy '{LAMBDA_HANDLER_FILE}' for testing...")
        with open(LAMBDA_HANDLER_FILE, 'w') as f:
            f.write("import json\nimport os\n\n")
            f.write("def lambda_handler(event, context):\n")
            f.write("    print(f'Hello from {os.environ.get(\"AWS_LAMBDA_FUNCTION_NAME\", \"Lambda\")}!')\n")
            f.write("    print(f'Received event: {json.dumps(event)}')\n")
            f.write("    return {'statusCode': 200, 'body': json.dumps('Hello from Lambda deployed by script!')}\n")

    if not os.path.exists(DEPENDENCIES_FILE):
        print(f"Creating dummy '{DEPENDENCIES_FILE}' for testing (e.g., with 'requests')...")
        with open(DEPENDENCIES_FILE, 'w') as f: f.write("requests\n")

    for folder_name in FOLDERS_TO_PACKAGE:
        folder_path = os.path.join(current_dir, folder_name)
        if not os.path.exists(folder_path):
            print(f"Creating dummy folder '{folder_name}/' for testing...")
            os.makedirs(folder_path)
            with open(os.path.join(folder_path, '__init__.py'), 'w') as f: f.write(f"# __init__.py for {folder_name}\n")
            if folder_name == 'api':
                 with open(os.path.join(folder_path, 'client.py'), 'w') as f: f.write(f"def test_api(): print('Hello from api.client')\n")
    print("----------------------------------------------")

    # --- Review Configuration ---
    print("\nReview Configuration:")
    print(f"  Lambda Function Name: {AWS_FUNCTION_NAME}")
    print(f"  Lambda Handler:       {AWS_HANDLER_NAME}")
    print(f"  Lambda Runtime:       {AWS_RUNTIME} (Ensure this is supported in {AWS_REGION})")
    print(f"  IAM Role ARN:         {AWS_IAM_ROLE_ARN} (Ensure correct trust policy for Lambda)")
    print(f"  AWS Region:           {AWS_REGION or 'Default (from AWS CLI config)'}")
    if AWS_S3_DEPLOYMENT_BUCKET:
        print(f"  Deployment via S3:    {AWS_S3_DEPLOYMENT_BUCKET}")
    else:
        print(f"  Deployment Method:    Direct ZIP upload")
    print(f"  Handler File:         {LAMBDA_HANDLER_FILE}")
    # ... (other config printouts) ...
    print("----------------------------------------------")

    # --- User Choice for Action ---
    should_deploy_lambda = False
    while True:
        print("\nChoose an action:")
        print("1. Create ZIP package only")
        print("2. Create ZIP package AND deploy to AWS Lambda")
        choice = input("Enter your choice (1 or 2): ").strip()
        if choice == '1':
            should_deploy_lambda = False
            print("\nAction: Create ZIP package only.")
            break
        elif choice == '2':
            should_deploy_lambda = True
            print("\nAction: Create ZIP package AND deploy to AWS Lambda.")
            # Perform pre-deployment IAM role ARN check only if deploying
            # Note: The "YOUR_ACCOUNT_ID" check was removed as user provided a full ARN.
            # A more robust check would be to validate the ARN format or existence if needed.
            if not AWS_IAM_ROLE_ARN or "YOUR_ACCOUNT_ID" in AWS_IAM_ROLE_ARN or "YOUR_LAMBDA_EXECUTION_ROLE_NAME" in AWS_IAM_ROLE_ARN:
                 print("\nERROR: 'AWS_IAM_ROLE_ARN' seems to be a placeholder. Please set it correctly before deploying.")
                 print("Exiting.")
                 exit()
            break
        else:
            print("Invalid choice. Please enter 1 or 2.")
    
    # --- Execute ---
    print("\nStarting process...\n")
    zip_file_created_path, deployment_outcome = create_and_deploy_lambda(
        lambda_handler_file=LAMBDA_HANDLER_FILE,
        dependencies_file=DEPENDENCIES_FILE,
        aws_lambda_function_name=AWS_FUNCTION_NAME,
        aws_lambda_handler=AWS_HANDLER_NAME,
        aws_lambda_runtime=AWS_RUNTIME,
        aws_iam_role_arn=AWS_IAM_ROLE_ARN,
        folders_to_include=FOLDERS_TO_PACKAGE,
        aws_deployment_region=AWS_REGION,
        aws_s3_bucket_for_upload=AWS_S3_DEPLOYMENT_BUCKET,
        lambda_timeout=LAMBDA_TIMEOUT_SECONDS,
        lambda_memory_size=LAMBDA_MEMORY_MB,
        lambda_env_variables=LAMBDA_ENVIRONMENT_VARIABLES,
        publish_new_version=True,
        perform_deployment=should_deploy_lambda # Pass user's choice
    )

    print("\n--- Process Summary ---")
    if zip_file_created_path:
        print(f"✅ Packaging successful. ZIP package is at: {zip_file_created_path}")
        if should_deploy_lambda:
            if deployment_outcome is True:
                print(f"✅ Deployment successful for function '{AWS_FUNCTION_NAME}'.")
            elif deployment_outcome is False:
                print(f"❌ Deployment FAILED for function '{AWS_FUNCTION_NAME}'.")
            # If deployment_outcome is None here, it means perform_deployment was True but something went wrong before deployment call
            # This case should ideally be covered by zip_file_created_path being None if packaging failed.
    else:
        print("❌ Packaging FAILED.")
        if should_deploy_lambda:
            print("❌ Deployment was not attempted due to packaging failure.")

    print("\n==============================================")
    print("Script execution finished.")