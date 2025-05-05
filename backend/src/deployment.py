import os
import subprocess
import zipfile

def read_dependencies_from_file(package_file):
    """Reads dependencies from a file and returns a list of them."""
    with open(package_file, 'r') as f:
        return [line.strip() for line in f.readlines() if line.strip()]

def create_deployment_package(lambda_file, package_file):
    # Step 1: Get the current working directory (project directory)
    project_dir = os.getcwd()

    # Step 2: Create the 'package' directory if it doesn't exist
    package_dir = os.path.join(project_dir, 'package')
    if not os.path.exists(package_dir):
        os.makedirs(package_dir)

    # Step 3: Read dependencies from the package.txt file
    dependencies = read_dependencies_from_file(package_file)

    # Step 4: Install dependencies from the package.txt file
    if dependencies:
        for dep in dependencies:
            print(f"Installing dependency: {dep}")
            subprocess.run(['pip', 'install', '--target', package_dir, dep])

    # Step 5: Create the .zip file for dependencies
    zip_file_path = os.path.join(project_dir, 'my_deployment_package.zip')
    
    # Step 6: Zip the 'package' folder with dependencies
    print(f"Creating ZIP file with dependencies: {zip_file_path}")
    with zipfile.ZipFile(zip_file_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
        for root, dirs, files in os.walk(package_dir):
            for file in files:
                zipf.write(os.path.join(root, file), os.path.relpath(os.path.join(root, file), package_dir))
    
    # Step 7: Add lambda_function.py to the ZIP file
    print(f"Adding {lambda_file} to the ZIP file.")
    with zipfile.ZipFile(zip_file_path, 'a', zipfile.ZIP_DEFLATED) as zipf:
        zipf.write(lambda_file, os.path.basename(lambda_file))

    print(f"Deployment package created: {zip_file_path}")


# Example usage:
lambda_function_file = 'lambda_function.py'  # Your lambda function file
package_file = 'package.txt'  # Your package.txt file containing list of dependencies

create_deployment_package(lambda_function_file, package_file)
