# tests/db/test_user_crud.py
import pytest
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError # For direct DB exceptions if not caught by custom ones
import datetime

# Assuming your schemas, models, and CRUD functions are importable
try:
    from database.CRUD.POST.User import post_User_CRUD_functions as user_post_crud
    from database.CRUD.GET.User import get_User_CRUD_functions as user_get_crud
    # Import PATCH and DELETE CRUD functions as you create tests for them
    # from database.CRUD.PATCH.User import patch_User_CRUD_functions as user_patch_crud
    # from database.CRUD.DELETE.User import delete_User_CRUD_functions as user_delete_crud

    from database.schema.POST.User.user_schema import UserCreate
    from database.schema.PATCH.User.user_schema import UserUpdate # For PATCH tests
    from database.models import User, UserTypeEnum
    from api.exceptions import ConflictException, NotFoundException, BadRequestException
except ImportError as e:
    print(f"Error importing application modules in test_user_crud.py: {e}")
    print("Ensure 'project_root' in conftest.py correctly points to your project's base directory.")
    raise

# The 'db_session' fixture (which is transactional and uses the temporary MySQL DB)
# is automatically injected by pytest from conftest.py

def test_crud_create_user_success(db_session: Session):
    """Test successful user creation at the CRUD level."""
    timestamp = datetime.datetime.utcnow().strftime("%Y%m%d%H%M%S%f")
    unique_email = f"crud_user_{timestamp}@example.com"
    unique_username = f"crud_user_{timestamp}"

    user_payload = UserCreate(
        email=unique_email,
        passwordHashed="test_password_crud",
        userType=UserTypeEnum.username, # Pass the enum member
        username=unique_username,
        profileImg="profile.jpg",
        deviceId="device_crud_001"
    )

    created_user = user_post_crud.create_user(user=user_payload, db=db_session)

    assert created_user is not None
    assert created_user.email == unique_email
    assert created_user.username == unique_username
    assert created_user.userId is not None
    assert created_user.userType == UserTypeEnum.username.value # CRUD returns the value
    assert created_user.profileImg == "profile.jpg"
    
    # Verify it's in the session (though it will be rolled back)
    user_in_session = db_session.query(User).filter(User.userId == created_user.userId).first()
    assert user_in_session is not None
    assert user_in_session.email == unique_email

def test_crud_create_user_duplicate_email_raises_conflict(db_session: Session):
    """Test CRUD user creation with a duplicate email raises ConflictException."""
    timestamp = datetime.datetime.utcnow().strftime("%Y%m%d%H%M%S%f")
    duplicate_email = f"crud_duplicate_email_{timestamp}@example.com"
    username1 = f"crud_dup_email_user1_{timestamp}"
    username2 = f"crud_dup_email_user2_{timestamp}"

    user_payload_1 = UserCreate(
        email=duplicate_email,
        passwordHashed="password123",
        userType=UserTypeEnum.email,
        username=username1
    )
    # Create the first user (it will be rolled back, but exists for this transaction)
    user_post_crud.create_user(user=user_payload_1, db=db_session)
    # db_session.flush() # Not strictly needed before the exception if the unique constraint is at DB level

    user_payload_2 = UserCreate(
        email=duplicate_email, # Same email
        passwordHashed="password456",
        userType=UserTypeEnum.email,
        username=username2
    )

    with pytest.raises(ConflictException) as excinfo:
        user_post_crud.create_user(user=user_payload_2, db=db_session)
    
    assert f"Email address '{duplicate_email}' already exists" in str(excinfo.value.detail)

def test_crud_create_user_duplicate_username_raises_conflict(db_session: Session):
    """Test CRUD user creation with a duplicate username raises ConflictException."""
    timestamp = datetime.datetime.utcnow().strftime("%Y%m%d%H%M%S%f")
    email1 = f"crud_dup_uname_email1_{timestamp}@example.com"
    email2 = f"crud_dup_uname_email2_{timestamp}@example.com"
    duplicate_username = f"crud_duplicate_username_{timestamp}"

    user_payload_1 = UserCreate(
        email=email1,
        passwordHashed="password123",
        userType=UserTypeEnum.username,
        username=duplicate_username
    )
    user_post_crud.create_user(user=user_payload_1, db=db_session)

    user_payload_2 = UserCreate(
        email=email2, 
        passwordHashed="password456",
        userType=UserTypeEnum.username,
        username=duplicate_username # Same username
    )

    with pytest.raises(ConflictException) as excinfo:
        user_post_crud.create_user(user=user_payload_2, db=db_session)
    
    assert f"Username '{duplicate_username}' already exists" in str(excinfo.value.detail)


def test_crud_get_user_by_id(db_session: Session):
    """Test fetching a user by ID at CRUD level."""
    timestamp = datetime.datetime.utcnow().strftime("%Y%m%d%H%M%S%f")
    email = f"crud_get_id_{timestamp}@example.com"
    username = f"crud_get_id_{timestamp}"
    
    user_payload = UserCreate(email=email, passwordHashed="pw", userType=UserTypeEnum.email, username=username)
    created_user_model = user_post_crud.create_user(user=user_payload, db=db_session)
    # db_session.flush() # Ensure ID is available if not auto-refreshed by create_user

    fetched_user = user_get_crud.getUserByUserId(userId=created_user_model.userId, db=db_session)
    assert fetched_user is not None
    assert fetched_user.userId == created_user_model.userId
    assert fetched_user.email == email

def test_crud_get_user_by_id_not_found_raises_exception(db_session: Session):
    """Test fetching a non-existent user by ID raises NotFoundException."""
    with pytest.raises(NotFoundException) as excinfo:
        user_get_crud.getUserByUserId(userId=99999999, db=db_session)
    assert "User with ID 99999999 not found" in str(excinfo.value.detail)

def test_crud_get_user_by_email(db_session: Session):
    """Test fetching a user by email at CRUD level."""
    timestamp = datetime.datetime.utcnow().strftime("%Y%m%d%H%M%S%f")
    email = f"crud_get_email_{timestamp}@example.com"
    username = f"crud_get_email_{timestamp}"

    user_payload = UserCreate(email=email, passwordHashed="pw", userType=UserTypeEnum.email, username=username)
    user_post_crud.create_user(user=user_payload, db=db_session)
    # db_session.flush()

    fetched_user = user_get_crud.getUserByEmail(email=email, db=db_session)
    assert fetched_user is not None
    assert fetched_user.email == email
    assert fetched_user.username == username

def test_crud_get_user_by_username(db_session: Session):
    """Test fetching a user by username at CRUD level."""
    timestamp = datetime.datetime.utcnow().strftime("%Y%m%d%H%M%S%f")
    email = f"crud_get_uname_email_{timestamp}@example.com"
    username = f"crud_get_uname_{timestamp}"

    user_payload = UserCreate(email=email, passwordHashed="pw", userType=UserTypeEnum.username, username=username)
    user_post_crud.create_user(user=user_payload, db=db_session)
    # db_session.flush()

    fetched_user = user_get_crud.getUserByUsername(username=username, db=db_session)
    assert fetched_user is not None
    assert fetched_user.username == username
    assert fetched_user.email == email

# TODO: Add CRUD tests for:
# - User PATCH operations (updateUserByUserId, updateUserByUsername)
#   - Test updating various fields.
#   - Test attempting to update with duplicate email/username (should raise ConflictException).
#   - Test updating a non-existent user (should raise NotFoundException).
# - User DELETE operations (deleteUserByUserId)
#   - Test successful deletion.
#   - Test deleting a non-existent user (should raise NotFoundException).
# - CRUD functions for all other entities (Category, Collection, Mission, etc.)
#   - Test create, get (by various criteria), update, delete for each.
#   - Pay attention to unique constraints and foreign key relationships.

'''
This DB/CRUD test file demonstrates:
* Using the `db_session` fixture, which is transactional and connected to the temporary MySQL database.
* Directly calling your CRUD functions (e.g., `user_post_crud.create_user`).
* Using `pytest.raises` to assert that your custom exceptions (`ConflictException`, `NotFoundException`) are correctly raised.
* Creating unique data within tests to avoid interference, even though the transaction will be rolled back.
* The rollback mechanism ensures that the database state is reset after each test function, providing good isolation for your DML operations.

This comprehensive setup should provide a production-grade testing environment for your FastAPI application with a MySQL backend, automatically managing the lifecycle of your test database. Remember to fill in tests for all your other entities and edge case
'''