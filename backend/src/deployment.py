import os
import subprocess
import zipfile

def read_dependencies_from_file(package_file):
    """Reads dependencies from a file and returns a list of them."""
    with open(package_file, 'r') as f:
        return [line.strip() for line in f.readlines() if line.strip()]

def add_folder_to_zip(zipf, folder_path, base_folder):
    """Recursively adds a folder and its contents to a ZIP file."""
    for root, dirs, files in os.walk(folder_path):
        for file in files:
            full_path = os.path.join(root, file)
            relative_path = os.path.relpath(full_path, base_folder)
            zipf.write(full_path, relative_path)

def create_deployment_package(lambda_file, package_file):
    # Step 1: Get the current working directory (project directory)
    project_dir = os.getcwd()

    # Step 2: Create the 'package' directory if it doesn't exist
    package_dir = os.path.join(project_dir, 'package')
    if not os.path.exists(package_dir):
        os.makedirs(package_dir)

    # Step 3: Read dependencies from the package.txt file
    dependencies = read_dependencies_from_file(package_file)

    # Step 4: Install dependencies into the package directory
    if dependencies:
        for dep in dependencies:
            print(f"Installing dependency: {dep}")
            subprocess.run(['pip', 'install', '--target', package_dir, dep])

    # Step 5: Create the .zip file for the deployment package
    zip_file_path = os.path.join(project_dir, 'my_deployment_package.zip')
    print(f"Creating ZIP file: {zip_file_path}")
    with zipfile.ZipFile(zip_file_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
        # Add installed dependencies
        add_folder_to_zip(zipf, package_dir, package_dir)

        # Add the lambda function
        print(f"Adding {lambda_file} to the ZIP file.")
        zipf.write(lambda_file, os.path.basename(lambda_file))

        # Add the 'api' and 'tools' folders
        for folder_name in ['api', 'tools']:
            folder_path = os.path.join(project_dir, folder_name)
            if os.path.exists(folder_path):
                print(f"Adding folder {folder_name} to the ZIP file.")
                add_folder_to_zip(zipf, folder_path, project_dir)
            else:
                print(f"Warning: Folder '{folder_name}' not found and will be skipped.")

    print(f"Deployment package created: {zip_file_path}")
# Example usage:
lambda_function_file = 'lambda_function.py'  # Your lambda function file
package_file = 'package.txt'  # Your package.txt file containing list of dependencies

create_deployment_package(lambda_function_file, package_file)