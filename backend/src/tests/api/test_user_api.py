# tests/api/test_user_api.py
from fastapi.testclient import TestClient
from sqlalchemy.orm import Session # For type hinting if you inspect db_session directly
import datetime
import pytest # For marks or advanced features if needed

# Assuming your schemas and models are importable due to conftest.py sys.path setup
# Adjust these imports if your project structure is different
try:
    from database.schema.POST.User.user_schema import UserCreate
    from database.models import User, UserTypeEnum # Import your SQLAlchemy model
    from api.exceptions import ConflictException, NotFoundException # Your custom exceptions
except ImportError as e:
    print(f"Error importing application modules in test_user_api.py: {e}")
    print("Ensure 'project_root' in conftest.py correctly points to your project's base directory.")
    raise

# The 'client' and 'db_session' fixtures are automatically injected by pytest from conftest.py

def test_createUser_api_success(client: TestClient, db_session: Session):
    """
    Test successful user creation via the API.
    The database changes will be rolled back by the db_session fixture.
    """
    timestamp = datetime.datetime.utcnow().strftime("%Y%m%d%H%M%S%f")
    unique_email = f"test_api_user_{timestamp}@example.com"
    unique_username = f"test_api_user_{timestamp}"

    user_data_payload = {
        "email": unique_email,
        "passwordHashed": "api_test_password",
        "userType": UserTypeEnum.email.value, # Use the enum's value
        "username": unique_username,
        "deviceId": "test_api_device_001"
    }

    # Path construction: /User (tableName) + /createUser (path from API_PATHS_POST)
    response = client.post("/User/createUser", json=user_data_payload)

    assert response.status_code == 200, f"Expected 200, got {response.status_code}. Response: {response.text}"
    
    created_user_data = response.json()
    assert created_user_data["email"] == unique_email
    assert created_user_data["username"] == unique_username
    assert "userId" in created_user_data
    assert created_user_data["userId"] is not None
    assert "passwordHashed" not in created_user_data # Ensure password hash isn't returned

    # Verify in the current transaction's session (this will be rolled back)
    user_in_db = db_session.query(User).filter(User.userId == created_user_data["userId"]).first()
    assert user_in_db is not None
    assert user_in_db.email == unique_email
    assert user_in_db.username == unique_username
    # Note: The 'fake_hashed_password' logic is in your CRUD, so db_user.passwordHashed will reflect that.
    assert user_in_db.passwordHashed == user_data_payload["passwordHashed"] + "notreallyhashed"

def test_createUser_api_duplicate_email(client: TestClient, db_session: Session):
    """Test API user creation with a duplicate email."""
    timestamp = datetime.datetime.utcnow().strftime("%Y%m%d%H%M%S%f")
    duplicate_email = f"api_duplicate_email_test_{timestamp}@example.com"
    username1 = f"api_dup_user1_{timestamp}"
    username2 = f"api_dup_user2_{timestamp}"

    user_data_1 = {
        "email": duplicate_email,
        "passwordHashed": "password123",
        "userType": UserTypeEnum.email.value,
        "username": username1
    }
    # Create the first user (this will be part of the rolled-back transaction)
    response1 = client.post("/User/createUser", json=user_data_1)
    assert response1.status_code == 200, f"Setup for duplicate email test failed. Response: {response1.text}"

    # Attempt to create another user with the same email
    user_data_2 = {
        "email": duplicate_email, # Same email
        "passwordHashed": "password456",
        "userType": UserTypeEnum.email.value,
        "username": username2 # Different username
    }
    response2 = client.post("/User/createUser", json=user_data_2)

    assert response2.status_code == 409 # ConflictException
    error_detail = response2.json().get("detail", "")
    assert f"Email address '{duplicate_email}' already exists" in error_detail

def test_createUser_api_missing_required_fields(client: TestClient):
    """Test API user creation with missing required fields (e.g., passwordHashed)."""
    timestamp = datetime.datetime.utcnow().strftime("%Y%m%d%H%M%S%f")
    email_for_incomplete = f"api_incomplete_{timestamp}@example.com"
    
    incomplete_user_data = {
        "email": email_for_incomplete,
        # "passwordHashed": "missing_password", # Intentionally missing
        "userType": UserTypeEnum.email.value,
        "username": f"api_incomplete_user_{timestamp}"
    }
    response = client.post("/User/createUser", json=incomplete_user_data)

    assert response.status_code == 422 # FastAPI/Pydantic validation error
    error_data = response.json()
    assert "detail" in error_data
    
    found_password_error = any(
        "passwordHashed" in error.get("loc", []) and "Field required" in error.get("msg", "").lower() # Pydantic 2.x
        or "passwordHashed" in error.get("loc", []) and "field required" in error.get("msg", "").lower() # Pydantic 1.x
        for error in error_data.get("detail", [])
    )
    assert found_password_error, "Error details should mention missing 'passwordHashed'"

def test_get_user_api_by_id_success(client: TestClient, db_session: Session):
    """Test successfully fetching a user by ID via API."""
    timestamp = datetime.datetime.utcnow().strftime("%Y%m%d%H%M%S%f")
    email_to_fetch = f"api_fetch_user_{timestamp}@example.com"
    username_to_fetch = f"api_fetch_user_{timestamp}"

    user_payload = {
        "email": email_to_fetch,
        "passwordHashed": "fetch_password",
        "userType": UserTypeEnum.email.value,
        "username": username_to_fetch
    }
    create_response = client.post("/User/createUser", json=user_payload)
    assert create_response.status_code == 200
    created_user_id = create_response.json()["userId"]

    # Path: /User/getUserByUserId?userId=<id>
    # Your `extractData` in `get_User_functions.py` seems to expect query params
    get_response = client.get(f"/User/getUserByUserId?userId={created_user_id}")
    
    assert get_response.status_code == 200
    fetched_user_data = get_response.json()
    assert fetched_user_data["userId"] == created_user_id
    assert fetched_user_data["email"] == email_to_fetch
    assert fetched_user_data["username"] == username_to_fetch

def test_get_user_api_not_found(client: TestClient):
    """Test fetching a non-existent user by ID via API."""
    non_existent_user_id = 999999999  # An ID highly unlikely to exist
    
    response = client.get(f"/User/getUserByUserId?userId={non_existent_user_id}")
    
    assert response.status_code == 404
    error_detail = response.json().get("detail", "").lower()
    assert f"user with id {non_existent_user_id} not found" in error_detail

# TODO: Add more API tests for:
# - Other User endpoints (GET by email/username, PATCH, DELETE)
# - Endpoints for all other entities (Category, Collection, Mission, etc.)
# - Test cases for invalid input types, boundary conditions.
# - Test cases for authentication/authorization if applicable (will require header mocking).
'''
This API test file demonstrates:
* Using the `client` and `db_session` fixtures.
* Creating unique data for each test run to avoid collisions.
* Testing success (200/201), conflict (409), and validation error (422) scenarios.
* Verifying data in the database *within the same transaction* (which will be rolled back).
* **No manual API-based cleanup is strictly needed in these tests** because the `db_session` fixture rolls back the transaction, and the `temporary_test_database` fixture drops the entire database at the end of the session. This makes the API tests cleaner.

Finally, I'll generate the example database (CRUD) test file.
'''