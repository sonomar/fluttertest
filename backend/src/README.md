# Kloppocar General Functions API

## 🚀 Overview

This project implements a versatile backend API designed for deployment as an AWS Lambda function fronted by API Gateway, and alternatively, as a standalone FastAPI server. It leverages SQLAlchemy with Alembic for robust database schema management and migrations, and integrates with AWS Cognito for user authentication, automatically creating local user records upon Cognito's PostConfirmation trigger.

The API provides a comprehensive set of CRUD operations for various entities such as Users, Categories, Communities, Collectibles, and more, structured for scalability and maintainability.

## ✨ Features

* **Dual Deployment Mode**:

  * AWS Lambda: Optimized for serverless deployment, handled by `lambda_function.py`.
  * FastAPI Server: Can be run locally for development and testing using `main.py`.
* **Automated AWS Lambda Deployment**: `deployment.py` script for packaging and deploying the Lambda function, including dependencies and S3 upload options.
* **Database Agnostic**: Uses SQLAlchemy ORM for database interactions.
* **Database Migrations**: Employs Alembic for managing database schema versions and migrations.
* **Dynamic API Routing**: API routes for GET, POST, PATCH, DELETE are dynamically registered in `main.py` based on configurations in `api/API_PATHS_*.py`.
* **AWS Cognito Integration**: Automatically creates a user in the application database when a new user confirms their signup in Cognito (`lambda_function.py`).
* **Dependency Management**: Python dependencies are listed in `package.txt`.

  If using VSCode, consider adding the following to your workspace or `settings.json` file to configure Python's type checking level:

  ```json
  {
    "python.analysis.typeCheckingMode": "basic"  // or "strict" for more rigorous checks
  }
  ```

  This helps in maintaining code quality and identifying potential bugs early through static analysis.

## 🏗️ Project Structure

```bash
kloopocarGeneralFunctions_deployment_package/
├── alembic/                            # Alembic migration scripts
├── alembic.ini                         # Alembic configuration
├── api/                                # API endpoint definitions and handlers
│   ├── GET/
│   ├── POST/
│   ├── PATCH/
│   ├── DELETE/
│   ├── routeCheckAll.py
│   ├── table.py
│   └── exceptions.py
├── database/                           # Database related files
│   ├── CRUD/                           # CRUD function modules
│   ├── schema/                         # Pydantic schemas for API request/response
│   ├── doc/                            # SQL creation and insert queries
│   ├── db.py                           # SQLAlchemy engine and session setup
│   └── models.py                       # SQLAlchemy ORM models
├── tools/                              # Utility scripts
│   ├── dev/
│   └── prod/
├── deployment.py                       # Script for AWS Lambda deployment
├── lambda_function.py                  # AWS Lambda handler
├── main.py                             # FastAPI application entry point
├── package.txt                         # Python dependencies
├── README.md                           # This file
└── ... (other configuration files)
```

## 📋 Prerequisites

* **Python**: Version 3.12 (as specified in `deployment.py`'s `AWS_RUNTIME`).

* **pip**: For installing Python packages.

* **AWS CLI**: Configured for deploying to AWS. (See [AWS CLI Installation Guide](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html))

  ### Install AWS CLI

  To install the AWS CLI on macOS:

  ```bash
  curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
  sudo installer -pkg AWSCLIV2.pkg -target /
  ```

  After installation, run:

  ```bash
  aws configure
  ```

  This will prompt you to enter your AWS Access Key, Secret Key, Region, and default output format.
  Ensure your IAM user or role has the necessary permissions, such as:

  * `sts:AssumeRole`
  * `lambda:*`
  * `secretsmanager:GetSecretValue`
  * `logs:*`
  * `cognito-idp:*` (if integrating with Cognito)

* **MySQL Database**: The application uses `pymysql` and SQLAlchemy, implying a MySQL-compatible database.

* **Docker** (Optional): If you plan to containerize the FastAPI application or build deployment packages in a consistent environment.

* **Alembic**: For database migrations. Installed via `package.txt`.

## ⚙️ Setup and Installation

1. **Clone the Repository** (if applicable)

   ```bash
   git clone <repository_url>
   cd kloopocarGeneralFunctions_deployment_package
   ```

2. **Create and Activate a Python Virtual Environment**:

   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. **Install Dependencies**:

   ```bash
   pip install -r package.txt
   ```

    Key dependencies include: `fastapi`, `uvicorn`, `sqlalchemy`, `alembic`, `pymysql`, `pydantic`, `boto3`.

4. **Configure Environment Variables for Local Development**:

    The application uses `database/db.py` which attempts to load database credentials. For local development, create a `.env` file in   the project root with the following variables (this file is typically gitignored):

    ```env
    DB_HOST=your_local_db_host
    DB_PORT=3306 # Or your MySQL port
    DB_USER=your_db_user
    DB_PASSWORD=your_db_password
    DB_NAME=kloppocar # Or your database name
    ENV=local # To signify local environment
    # For AWS Lambda, secret_key is used by tools/prod/prodTools.py
    # For local development, this isn't strictly necessary if
    ENV=local
    # secret_key=your_aws_secret_name_for_local_testing_if_needed
    ```

    Refer to `tools/prod/prodTools.py` and `database/db.py` for how secrets and database connections are handled.

5. **Database Setup and Migrations**:

    This project uses Alembic for database migrations.

    * **Configure Alembic**:

    * Ensure `alembic.ini` has the correct `sqlalchemy.url`. For local development, it might look like:

    ```ini
    sqlalchemy.url = mysql+pymysql://your_db_user:your_db_password@your_local_db_host/kloppocar
    ```

    The `env.py` script (likely `alembic/env.py` or a custom one based on templates) should target the `Base.metadata` from `database.models`.

    * **Create Initial Migration (if starting fresh)**:

    If you're setting up the database for the first time and models exist in `database/models.py`:

    ```bash
    alembic revision -m "create initial tables" --autogenerate
    ```

    This command when you want to generate custom migration
    ```bash
    alembic revision -m "Manually migrate all text and varchar data to JSON format"
    ```

    * **Apply Migrations**:

    To apply all pending migrations to your database:

    ```bash
    alembic upgrade head
    ```

## ධ Running Locally (FastAPI Server)

To run the application as a FastAPI server locally (primarily for development and testing API endpoints):

```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

The application will be available at [http://localhost:8000](http://localhost:8000). The `main.py` file sets up the FastAPI app and dynamically registers routes.

## ☁️ Deployment to AWS Lambda

The `deployment.py` script automates the packaging and deployment of this application as an AWS Lambda function.

### 1. **AWS CLI Configuration**:

Ensure your AWS CLI is installed and configured with necessary permissions.

   ```bash
   aws configure
   ```

The script `deployment.py` checks for AWS CLI availability and identity.

### 2. **IAM Role and Permissions**:

The Lambda function requires an IAM role with permissions to:

* Execute Lambda functions (`AWSLambdaBasicExecutionRole`).
* Read secrets from AWS Secrets Manager (e.g., `secretsmanager:GetSecretValue` if `ENV=production`).
* Interact with AWS Cognito if Cognito triggers are used (e.g., `Cognito-authenticated-*`).
* Log to CloudWatch Logs.
* Permissions for any other AWS services the Lambda interacts with (e.g., S3 if `AWS_S3_DEPLOYMENT_BUCKET` is used).

An example IAM Role ARN is provided in `deployment.py` (replace with your actual ARN).

### 3. **Configure `deployment.py`**:

Open `deployment.py` and modify the --- Core Configuration --- section as needed:

* `LAMBDA_HANDLER_FILE`: Should be `lambda_function.py`.
* `DEPENDENCIES_FILE`: Should be `package.txt`.
* `AWS_FUNCTION_NAME`: Your desired Lambda function name (e.g., `kloopocarGeneralFunctions`).
* `AWS_HANDLER_NAME`: The handler path (e.g., `lambda_function.lambda_handler`).
* `AWS_RUNTIME`: Python runtime (e.g., `python3.12`).
* `AWS_IAM_ROLE_ARN`: Crucial: Update this with the ARN of the IAM role created for the Lambda.
* `AWS_REGION`: The AWS region for deployment (e.g., `eu-central-1`).
* `AWS_S3_DEPLOYMENT_BUCKET` (Optional): If you want to deploy via S3, set this to your S3 bucket name. Otherwise, it will do a direct ZIP upload.
* `LAMBDA_TIMEOUT_SECONDS`, `LAMBDA_MEMORY_MB`.
* `LAMBDA_ENVIRONMENT_VARIABLES`: Set environment variables for the Lambda, including `ENV=production` and `secret_key` (ARN for AWS Secrets Manager).
* `FOLDERS_TO_PACKAGE`: List of folders to include in the deployment package.

4. **Run Deployment Script**:

The script offers two modes: packaging only, or packaging and deploying.

   ```bash
   python deployment.py
   ```

You will be prompted to choose an action:

1. **Create ZIP package only**: This will create `kloopocarGeneralFunctions_deployment_package.zip` (or similar, based on `AWS_FUNCTION_NAME`) in your project root.
2. **Create ZIP package AND deploy to AWS Lambda**: This will package and then attempt to create or update the Lambda function on AWS.

The script handles:

* Reading dependencies from `package.txt` and packaging them for a Lambda-compatible environment (`manylinux2014_x86_64`).
* Including specified folders (`api`, `tools`, `database` by default).
* Creating or updating the Lambda function with the specified configuration.
* Optionally uploading the deployment package to S3 first.

## 🗄️ Database Migrations (Alembic)

Alembic is used for database schema migrations, configured via `alembic.ini` and the `env.py` script (typically located in `alembic/env.py` after `alembic init`).

### Environment Setup (`alembic/env.py`):

This file is crucial for Alembic. It should be configured to:

* Point to your database URL (can be read from `alembic.ini` or environment variables).
* Import and set `target_metadata = Base.metadata` from your `database.models` (or wherever your SQLAlchemy Base and models are defined). This allows Alembic to autogenerate migrations by comparing your models to the database state.

###  **Generating a New Migration**:

After making changes to your SQLAlchemy models in `database/models.py`:

  ```bash
  alembic revision -m "your_migration_message_here" --autogenerate
  ```

This will compare your models against the database schema (as per `sqlalchemy.url` in `alembic.ini`) and generate a new revision script in the `alembic/versions/` directory. Review the generated script carefully.

### **Applying Migrations**:
To apply pending migrations to the database:

  ```bash
  alembic upgrade head
  ```

To upgrade to a specific revision:

```bash
alembic upgrade <revision_id>
```

### **Downgrading Migrations**:

To downgrade to a specific revision:

  ```bash
  alembic downgrade <revision_id>
  ```

To downgrade by one step:

```bash
alembic downgrade -1
```
Checking Current Revision:

```bash
alembic current
```
<br>
<br>

### ⚙️ Managing Complex or Trigger-Based Migrations (`manage_trigger_migrations.py`)

In addition to Alembic, this project includes a custom migration utility script:  
`tools/dev/manage_trigger_migrations.py`.

This script is useful for applying SQL migrations that go beyond standard table creation or alteration, such as:

- Adding, modifying, or dropping database **triggers**
- Creating or altering **stored procedures**
- Executing **custom raw SQL** not easily expressed via SQLAlchemy

This is especially helpful when evolving business logic directly in the database layer.

#### ✅ Usage

From the root directory of the project, run:

```bash
python tools/dev/manage_trigger_migrations.py
```

This script will:

1. **Connect to the MySQL database** using credentials from the environment or `.env` file.
2. **Scan and execute SQL scripts** found in a configured folder (e.g., `database/doc/triggers/` or similar).
3. Log which files were run and handle basic error reporting.

> 📝 By default, SQL scripts should be placed in a subdirectory like `database/doc/triggers/` and should be named clearly by purpose (e.g., `on_user_insert_trigger.sql`, `project_update_logic.sql`).

#### 📁 Expected SQL Folder Structure

```bash
database/
└── doc/
    └── triggers/
        ├── user_on_create_trigger.sql
        ├── update_collectible_status.sql
        └── ...
```

#### 🛠️ Customization

If you need to change:

- **Folder location** for SQL scripts
- **File execution order**
- **Database connection logic**

Edit the script:  
`tools/dev/manage_trigger_migrations.py`

Make sure to include error handling and logging if adapting this for production use.

#### 🔐 Database Credentials

The script uses the same `.env` configuration as the main app. Ensure the following variables are available:

```env
DB_HOST=...
DB_PORT=...
DB_USER=...
DB_PASSWORD=...
DB_NAME=...
ENV=local
```

These are loaded by `load_dotenv()` from the root `.env` file.

---

> ℹ️ Use `manage_trigger_migrations.py` **in addition to Alembic**, not as a replacement. It’s meant for SQL-level logic that doesn’t map cleanly to SQLAlchemy models.


## 🔗 API Endpoints

The API is structured with FastAPI and a dynamic routing mechanism.

* **FastAPI (main.py)**: Sets up the FastAPI application. It dynamically registers routes for GET, POST, PATCH, and DELETE methods based on configurations in:

  * `api/GET/api_paths_get.py`
  * `api/POST/api_paths_post.py`
  * `api/PATCH/api_paths_patch.py`
  * `api/DELETE/api_paths_delete.py`

These files map paths to handler functions located in the `database/CRUD/` subdirectories.

* **Lambda Handler (**\`\`**)**:

  * For API Gateway events, it routes requests via `api.routeCheckAll.http_router_all`, which in turn uses HTTP method-specific routers (`http_router_get`, `http_router_post`, etc.). These routers then call table-specific functions to find the correct handler.
  * This setup appears to be a bridge between an older routing style and the newer FastAPI approach. For direct Lambda invocation without FastAPI (or using a shim like Mangum), this is the entry point.

Due to the dynamic and extensive nature of the API (covering tables like User, Category, Community, Collection, Project, Collectible, etc.), please refer to the `API_PATHS_*.py` files for specific endpoint paths and their corresponding handler functions.


## 🔑 AWS Cognito Integration

The `lambda_function.py` includes logic to handle AWS Cognito triggers:

* **Trigger Source**: `PostConfirmation_ConfirmSignUp`
* **Action**: When a user confirms their sign-up in Cognito, this Lambda function is triggered. It extracts user attributes (email, Cognito username) and creates a corresponding user record in the application's database using `database.CRUD.POST.User.post_User_CRUD_functions.createUser`.
* The password for the local database user is a placeholder (`COGNITO_MANAGED_USER`), as Cognito manages the actual user authentication.

## 🤝 Contributing

(Optional: Add guidelines for contributing to this project, e.g., coding standards, branch strategy, pull request process.)

## 📜 License

(Optional: Specify the license for this project, e.g., MIT, Apache 2.0.)