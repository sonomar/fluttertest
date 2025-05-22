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
        # Exclude __pycache__ directories and .pyc files
        dirs[:] = [d for d in dirs if d != '__pycache__']
        files = [f for f in files if not f.endswith('.pyc')]

        for file in files:
            full_path = os.path.join(root, file)
            archive_name = os.path.relpath(full_path, base_folder_to_strip)
            zipf.write(full_path, archive_name)
        # Add empty directories if necessary (though often not explicitly needed for Lambda structure)
        # for adir in dirs:
        #     full_path = os.path.join(root, adir)
        #     archive_name = os.path.relpath(full_path, base_folder_to_strip)
        #     # Ensure it's treated as a directory in the zip.
        #     # ZipFile automatically creates directory entries if files are placed within them.
        #     # Explicitly adding might be needed if an empty dir must exist.
        #     if not os.listdir(full_path): # if directory is empty
        #         zipf.write(full_path, archive_name + '/')


def check_aws_cli():
    """Checks if AWS CLI is installed and minimally configured."""
    try:
        subprocess.run(['aws', '--version'], check=True, capture_output=True, text=True)
        # A more robust check for configuration:
        identity_check = subprocess.run(['aws', 'sts', 'get-caller-identity'], check=True, capture_output=True, text=True)
        print(f"AWS CLI found and configured. Caller Identity: {identity_check.stdout.strip()}")
        return True
    except FileNotFoundError:
        print("ERROR: AWS CLI not found. Please install it and ensure it's in your PATH.")
        print("See: https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html")
        return False
    except subprocess.CalledProcessError as e:
        print("ERROR: AWS CLI is present but not configured correctly or lacks permissions.")
        print(f"Command failed: {' '.join(e.cmd)}")
        print(f"Error: {e.stderr}")
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
            raise # Re-raise for other AWS CLI errors

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
            # Update function code
            cmd_update_code = aws_command_base + [
                'update-function-code',
                '--function-name', function_name
            ] + code_location_args
            if publish:
                cmd_update_code.append('--publish')
            
            print(f"Executing: {' '.join(cmd_update_code[:5])} ... (code args hidden for brevity)")
            result_code = subprocess.run(cmd_update_code, check=True, capture_output=True, text=True)
            print(f"Function code updated. Version: {json.loads(result_code.stdout).get('Version', 'N/A')}")

            # --- !!! ADDED WAITER !!! ---
            print(f"Waiting for function '{function_name}' code update to complete...")
            cmd_wait_code_update = aws_command_base + [
                'wait', 'function-updated',
                '--function-name', function_name
            ]
            # The waiter can take some time, especially for larger functions or container images.
            # Default waiter timeout is usually sufficient, but can be configured if needed.
            subprocess.run(cmd_wait_code_update, check=True, capture_output=True, text=True)
            print(f"Function '{function_name}' is now updated and ready for configuration changes.")
            # --- !!! END OF WAITER !!! ---

            # Update function configuration
            print("Updating function configuration...")
            cmd_update_config = aws_command_base + [
                'update-function-configuration',
                '--function-name', function_name,
                '--runtime', runtime,
                '--role', role_arn,
                '--handler', handler,
                '--timeout', str(timeout),
                '--memory-size', str(memory_size)
            ]
            if environment_variables:
                env_vars_string = ",".join([f"{k}={v}" for k, v in environment_variables.items()])
                cmd_update_config.extend(['--environment', f"Variables={{{env_vars_string}}}"])
            
            print(f"Executing: {' '.join(cmd_update_config[:5])} ...")
            subprocess.run(cmd_update_config, check=True, capture_output=True, text=True)
            print("Function configuration updated successfully.")

        else: # Creating new function (waiter not typically needed here before first config)
            print(f"Creating new Lambda function '{function_name}'...")
            cmd_create = aws_command_base + [
                'create-function',
                '--function-name', function_name,
                '--runtime', runtime,
                '--role', role_arn,
                '--handler', handler,
                '--timeout', str(timeout),
                '--memory-size', str(memory_size)
            ] + code_location_args
            if environment_variables:
                env_vars_string = ",".join([f"{k}={v}" for k, v in environment_variables.items()])
                cmd_create.extend(['--environment', f"Variables={{{env_vars_string}}}"])
            if publish:
                cmd_create.append('--publish')

            print(f"Executing: {' '.join(cmd_create[:5])} ... (code args hidden for brevity)")
            result_create = subprocess.run(cmd_create, check=True, capture_output=True, text=True)
            created_function_arn = json.loads(result_create.stdout)['FunctionArn']
            print(f"Successfully created Lambda function. ARN: {created_function_arn}")

            # Wait for the new function to be fully active before any potential immediate follow-up (though not in this script flow)
            print(f"Waiting for new function '{function_name}' to become active...")
            cmd_wait_creation = aws_command_base + [
                'wait', 'function-active-v2', # 'function-active-v2' is a more modern waiter
                '--function-name', function_name
            ]
            subprocess.run(cmd_wait_creation, check=True, capture_output=True, text=True)
            print(f"New function '{function_name}' is active.")
        
        return True

    except subprocess.CalledProcessError as e:
        print(f"ERROR during AWS CLI command execution for function '{function_name}':")
        print(f"Command: {' '.join(e.cmd)}") # Be cautious if commands contain sensitive info
        print(f"Return code: {e.returncode}")
        stderr_output = e.stderr.strip() if e.stderr else "No stderr output"
        stdout_output = e.stdout.strip() if e.stdout else "No stdout output" # Some AWS errors go to stdout
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
    folders_to_include=None, # e.g., ['api', 'tools', 'database']
    aws_deployment_region=None,
    aws_s3_bucket_for_upload=None,
    lambda_timeout=60,
    lambda_memory_size=256,
    lambda_env_variables=None,
    publish_new_version=True
):
    """
    Packages the Lambda function, its dependencies, and specified folders,
    then deploys it to AWS Lambda.
    """
    if not check_aws_cli():
        print("Aborting due to AWS CLI issues.")
        return False

    project_dir = os.getcwd()
    # Use a temporary directory for packaging, ensure it's cleaned up
    package_build_dir_name = 'lambda_package_build_temp'
    package_build_dir = os.path.join(project_dir, package_build_dir_name)

    if os.path.exists(package_build_dir):
        print(f"Removing existing temporary package build directory: {package_build_dir}")
        shutil.rmtree(package_build_dir)
    os.makedirs(package_build_dir)
    print(f"Created temporary package build directory: {package_build_dir}")

    dependencies = read_dependencies_from_file(dependencies_file)
    if dependencies:
        print("\nInstalling dependencies...")
        for dep in dependencies:
            print(f"Installing: {dep} into {package_build_dir}")
            # Note on pip install options:
            # --platform manylinux2014_x86_64 is good for Lambda compatibility on Amazon Linux 2.
            # --python-version should ideally align with your Lambda runtime for compiled extensions.
            # --implementation cp (CPython) is standard.
            # --only-binary :all: can speed up if wheels are available.
            pip_command = [
                'pip', 'install',
                '--target', package_build_dir,
                '--platform', 'manylinux2014_x86_64',
                '--implementation', 'cp',
                '--python-version', aws_lambda_runtime.replace('python',''), # e.g. 3.12 from python3.12
                '--only-binary', ':all:',
                '--upgrade',
                dep
            ]
            try:
                # Capture output for better debugging if needed
                result = subprocess.run(pip_command, check=True, capture_output=True, text=True)
                if result.stdout: print(f"Pip install stdout for {dep}:\n{result.stdout}")
                if result.stderr: print(f"Pip install stderr for {dep}:\n{result.stderr}")
            except subprocess.CalledProcessError as e:
                print(f"ERROR: Failed to install dependency: {dep}")
                print(f"Command: {' '.join(e.cmd)}")
                print(f"Stderr: {e.stderr}")
                print(f"Stdout: {e.stdout}")
                shutil.rmtree(package_build_dir) # Clean up
                return False
    else:
        print("\nNo dependencies found in package.txt or file not present.")

    # Create the .zip file for the deployment package
    zip_file_name = f"{aws_lambda_function_name}_deployment_package.zip"
    zip_file_path = os.path.join(project_dir, zip_file_name) # Create zip in project root

    print(f"\nCreating ZIP file: {zip_file_path}")
    with zipfile.ZipFile(zip_file_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
        # Add installed dependencies from the package_build_dir
        if os.path.exists(package_build_dir) and os.listdir(package_build_dir):
            print(f"Adding dependencies from '{package_build_dir}' to ZIP.")
            add_folder_to_zip(zipf, package_build_dir, package_build_dir) # base_folder strips package_build_dir itself
        
        # Add the lambda handler file
        if os.path.exists(lambda_handler_file):
            print(f"Adding Lambda handler '{lambda_handler_file}' to ZIP as '{os.path.basename(lambda_handler_file)}'.")
            zipf.write(lambda_handler_file, os.path.basename(lambda_handler_file))
        else:
            print(f"ERROR: Lambda handler file '{lambda_handler_file}' not found!")
            shutil.rmtree(package_build_dir)
            return False

        # Add other specified folders (e.g., 'api', 'tools')
        if folders_to_include:
            for folder_name in folders_to_include:
                folder_path = os.path.join(project_dir, folder_name)
                if os.path.exists(folder_path) and os.path.isdir(folder_path):
                    print(f"Adding folder '{folder_name}' to the ZIP file.")
                    # This will add 'folder_name/...' to the zip
                    add_folder_to_zip(zipf, folder_path, project_dir)
                else:
                    print(f"Warning: Folder '{folder_name}' not found at '{folder_path}' or is not a directory, skipping.")

    print(f"Deployment package created: {zip_file_path} (Size: {os.path.getsize(zip_file_path) / 1024:.2f} KB)")

    # Clean up the temporary package build directory
    print(f"Cleaning up temporary package build directory: {package_build_dir}")
    shutil.rmtree(package_build_dir)

    # --- Deployment Step ---
    s3_key_for_upload = None
    if aws_s3_bucket_for_upload:
        # Create a unique-ish key, perhaps with a timestamp or version
        s3_key_for_upload = f"lambda-deployments/{aws_lambda_function_name}/{os.path.basename(zip_file_path)}"
        if not upload_to_s3(zip_file_path, aws_s3_bucket_for_upload, s3_key_for_upload, aws_deployment_region):
            print("Failed to upload to S3. Aborting deployment.")
            return False
    
    deploy_success = deploy_lambda_function(
        zip_file_path=zip_file_path,
        function_name=aws_lambda_function_name,
        handler=aws_lambda_handler,
        runtime=aws_lambda_runtime,
        role_arn=aws_iam_role_arn,
        region=aws_deployment_region,
        s3_bucket=aws_s3_bucket_for_upload if s3_key_for_upload else None, # Pass S3 details only if upload was done
        s3_key=s3_key_for_upload if s3_key_for_upload else None,
        timeout=lambda_timeout,
        memory_size=lambda_memory_size,
        environment_variables=lambda_env_variables,
        publish=publish_new_version
    )

    if deploy_success:
        print(f"\nLambda function '{aws_lambda_function_name}' deployed successfully.")
        # Optionally, remove local zip after successful S3 upload and deployment
        # if aws_s3_bucket_for_upload and os.path.exists(zip_file_path):
        #     os.remove(zip_file_path)
        #     print(f"Removed local zip file: {zip_file_path}")
    else:
        print(f"\nLambda function '{aws_lambda_function_name}' deployment FAILED.")

    return deploy_success


# ==============================================================================
# Example Usage: Configure and run this section
# ==============================================================================
if __name__ == "__main__":
    print("Starting Lambda Packaging and Deployment Script")
    print("==============================================")

    # --- Core Configuration - MODIFY THESE VALUES ---
    # Assumes this script is in the root of your project directory.
    # Project structure example:
    # your_project_root/
    #  ├── lambda_function.py  (your main Lambda handler code)
    #  ├── package.txt         (list of pip dependencies)
    #  ├── deploy_script.py    (this script)
    #  ├── api/                (example custom folder to include)
    #  │   └── client.py
    #  └── tools/              (example custom folder to include)
    #      └── utils.py

    LAMBDA_HANDLER_FILE = 'lambda_function.py'
    DEPENDENCIES_FILE = 'package.txt' # File listing pip dependencies, one per line

    # AWS Lambda Specifics - **YOU MUST CHANGE THESE**
    AWS_FUNCTION_NAME = 'kloopocarGeneralFunctions'
    AWS_HANDLER_NAME = 'lambda_function.lambda_handler' # Format: filename_without_py.function_name
    AWS_RUNTIME = 'python3.13' # IMPORTANT: Use a runtime supported by AWS Lambda (e.g., python3.9, python3.10, python3.11, python3.12)
    #AWS_IAM_ROLE_ARN = 'arn:aws:iam::YOUR_ACCOUNT_ID:role/YOUR_LAMBDA_EXECUTION_ROLE_NAME' # ** Replace with your actual IAM Role ARN **
    AWS_IAM_ROLE_ARN = 'arn:aws:iam::557690594992:role/service-role/Admin'
    # Optional AWS Configuration
    AWS_REGION = 'eu-central-1'  # e.g., 'us-east-1', 'eu-west-2'. If None, AWS CLI default is used.
    AWS_S3_DEPLOYMENT_BUCKET = None # 'your-s3-bucket-for-lambda-zips' # OPTIONAL: If package is large or you prefer S3. Bucket must exist.
    
    # Lambda Function Settings
    LAMBDA_TIMEOUT_SECONDS = 45
    LAMBDA_MEMORY_MB = 192 # Min 128MB.
    LAMBDA_ENVIRONMENT_VARIABLES = {
        "LOG_ENV": "production",
        "EXAMPLE_VAR": "HelloFromLambdaEnv",
        "secret_key": "arn:aws:secretsmanager:eu-central-1:557690594992:secret:kloopoSecrets-fP2FiS"
    }
    # List of additional folders (relative to project root) to include in the zip
    # Their internal structure will be preserved in the zip.
    # e.g., if 'api/client.py' exists, it will be 'api/client.py' in the zip.
    FOLDERS_TO_PACKAGE = ['api', 'tools', 'database'] # Add your folder names here

    # --- Sanity Checks & Dummy File Creation for Testing ---
    # This part helps in testing the script if you don't have these files yet.
    current_dir = os.getcwd()
    if not os.path.exists(LAMBDA_HANDLER_FILE):
        print(f"Creating dummy '{LAMBDA_HANDLER_FILE}' for testing...")
        with open(LAMBDA_HANDLER_FILE, 'w') as f:
            f.write("import json\nimport os\n\n")
            f.write("def lambda_handler(event, context):\n")
            f.write("    print(f'Hello from {os.environ.get(\"AWS_LAMBDA_FUNCTION_NAME\", \"Lambda\")}!')\n")
            f.write("    print(f'Received event: {json.dumps(event)}')\n")
            f.write("    print(f'LOG_LEVEL: {os.environ.get(\"LOG_LEVEL\")}')\n")
            f.write("    try:\n")
            f.write("        from api import client  # Example import\n")
            f.write("        client.test_api()\n")
            f.write("    except ImportError:\n")
            f.write("        print('Could not import from api folder. Ensure it is packaged.')\n")
            f.write("    except AttributeError:\n")
            f.write("        print('api.client does not have test_api. Ensure dummy files are correct.')\n")
            f.write("    return {'statusCode': 200, 'body': json.dumps('Hello from Lambda deployed by script!')}\n")

    if not os.path.exists(DEPENDENCIES_FILE):
        print(f"Creating dummy '{DEPENDENCIES_FILE}' for testing (e.g., with 'requests')...")
        with open(DEPENDENCIES_FILE, 'w') as f:
            f.write("requests\n")
            f.write("# boto3 # Often included in Lambda runtime, but can be bundled if specific version needed\n")

    for folder_name in FOLDERS_TO_PACKAGE:
        folder_path = os.path.join(current_dir, folder_name)
        if not os.path.exists(folder_path):
            print(f"Creating dummy folder '{folder_name}/' for testing...")
            os.makedirs(folder_path)
            # Add a dummy __init__.py to make it a package and a dummy module
            with open(os.path.join(folder_path, '__init__.py'), 'w') as f:
                f.write(f"# __init__.py for {folder_name}\n")
            if folder_name == 'api': # Example with a submodule
                 with open(os.path.join(folder_path, 'client.py'), 'w') as f:
                    f.write(f"def test_api():\n    print('Hello from {folder_name}.client.test_api()')\n")
            else:
                 with open(os.path.join(folder_path, f'{folder_name}_utils.py'), 'w') as f:
                    f.write(f"def test_util():\n    print('Hello from {folder_name}_utils.test_util()')\n")
    print("----------------------------------------------")

    # --- Pre-run User Confirmation ---
    print("\nReview Configuration:")
    print(f"  Lambda Function Name: {AWS_FUNCTION_NAME}")
    print(f"  Lambda Handler:       {AWS_HANDLER_NAME}")
    print(f"  Lambda Runtime:       {AWS_RUNTIME}")
    print(f"  IAM Role ARN:         {AWS_IAM_ROLE_ARN}")
    print(f"  AWS Region:           {AWS_REGION or 'Default (from AWS CLI config)'}")
    print(f"  S3 Bucket for Upload: {AWS_S3_DEPLOYMENT_BUCKET or 'None (direct upload)'}")
    print(f"  Handler File:         {LAMBDA_HANDLER_FILE}")
    print(f"  Dependencies File:    {DEPENDENCIES_FILE}")
    print(f"  Folders to Package:   {FOLDERS_TO_PACKAGE}")
    print(f"  Timeout:              {LAMBDA_TIMEOUT_SECONDS}s")
    print(f"  Memory:               {LAMBDA_MEMORY_MB}MB")
    print(f"  Environment Vars:     {LAMBDA_ENVIRONMENT_VARIABLES}")
    print("----------------------------------------------")

    if "YOUR_ACCOUNT_ID" in AWS_IAM_ROLE_ARN or "YOUR_LAMBDA_EXECUTION_ROLE_NAME" in AWS_IAM_ROLE_ARN :
        print("\nERROR: Please update 'AWS_IAM_ROLE_ARN' in the script with your actual IAM Role ARN.")
        print("Deployment aborted.")
    else:
        proceed = input("Do you want to proceed with packaging and deployment? (yes/no): ")
        if proceed.lower() == 'yes':
            print("\nStarting deployment process...\n")
            create_and_deploy_lambda(
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
                publish_new_version=True
            )
        else:
            print("Deployment cancelled by user.")

    print("\n==============================================")
    print("Script execution finished.")