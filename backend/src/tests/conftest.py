# tests/conftest.py
import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine, text, URL
from sqlalchemy.orm import sessionmaker, Session
from sqlalchemy.exc import OperationalError, ProgrammingError
from sqlalchemy.pool import NullPool
import os
import sys
import uuid
from dotenv import load_dotenv
import pymysql
import logging

# --- Project Path Setup ---
project_root = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
if project_root not in sys.path:
    sys.path.insert(0, project_root)

# --- Application Imports ---
try:
    from database.db import Base, get_db
    from main import app
except ImportError as e:
    print(f"CRITICAL ERROR [conftest.py]: Failed to import application modules (Base, get_db, app): {e}")
    raise

# --- Environment Variable Loading ---
dotenv_path = os.path.join(project_root, '.env')
if os.path.exists(dotenv_path):
    load_dotenv(dotenv_path)
    print(f"DEBUG [conftest.py]: Loaded environment variables from: {dotenv_path}")
else:
    print(f"DEBUG [conftest.py]: Warning: .env file not found at {dotenv_path}.")

# --- Database Credentials ---
ADMIN_DB_USER = os.getenv("TEST_DB_SUPERUSER", "root")
ADMIN_DB_PASSWORD = os.getenv("TEST_DB_SUPERPASSWORD", "")
ADMIN_DB_HOST = os.getenv("TEST_DB_HOST", "localhost")
ADMIN_DB_PORT = int(os.getenv("TEST_DB_PORT", 3306))
DB_CHARSET = 'utf8mb4'

APP_TEST_DB_USER = os.getenv("TEST_DB_APP_USER", "kloopotestuser")
APP_TEST_DB_PASSWORD = os.getenv("TEST_DB_APP_PASSWORD", "")

print(f"DEBUG [conftest.py]: Admin Credentials for DB Create/Drop -> User: '{ADMIN_DB_USER}', PasswordSet: {'YES' if ADMIN_DB_PASSWORD else 'NO'}, Host: '{ADMIN_DB_HOST}', Port: {ADMIN_DB_PORT}")
print(f"DEBUG [conftest.py]: App Credentials for Test DB Connect -> User: '{APP_TEST_DB_USER}', PasswordSet: {'YES' if APP_TEST_DB_PASSWORD else 'NO'}, Host: '{ADMIN_DB_HOST}', Port: {ADMIN_DB_PORT}")

_test_db_sqlalchemy_engine = None
_current_test_db_name = None

def _execute_admin_sql_direct_pymysql(sql_statement: str, commit: bool = True, database_context: str = "mysql"):
    admin_conn = None
    try:
        admin_conn = pymysql.connect(
            host=ADMIN_DB_HOST, user=ADMIN_DB_USER, password=ADMIN_DB_PASSWORD,
            database=database_context, port=ADMIN_DB_PORT, charset=DB_CHARSET, connect_timeout=10
        )
        with admin_conn.cursor() as cursor:
            cursor.execute(sql_statement)
        if commit:
            admin_conn.commit()
    except Exception as e:
        print(f"ERROR_ADMIN_SQL: Failed to execute '{sql_statement}' on system DB '{database_context}'. Error: {type(e).__name__}: {e}")
        raise
    finally:
        if admin_conn:
            admin_conn.close()

@pytest.fixture(scope="session")
def temporary_test_database():
    global _test_db_sqlalchemy_engine, _current_test_db_name

    _current_test_db_name = f"test_kloppocar_{uuid.uuid4().hex[:8]}"
    print(f"\nSETUP [temporary_test_database]: Attempting to create temporary test database: {_current_test_db_name} using admin user '{ADMIN_DB_USER}'")

    try:
        _execute_admin_sql_direct_pymysql(f"CREATE DATABASE `{_current_test_db_name}` CHARACTER SET {DB_CHARSET} COLLATE {DB_CHARSET}_unicode_ci;")
        print(f"SETUP [temporary_test_database]: Successfully created database: {_current_test_db_name}")

        if APP_TEST_DB_USER != ADMIN_DB_USER:
            print(f"SETUP [temporary_test_database]: Granting privileges on '{_current_test_db_name}' to '{APP_TEST_DB_USER}'.")
            _execute_admin_sql_direct_pymysql(f"GRANT ALL PRIVILEGES ON `{_current_test_db_name}`.* TO '{APP_TEST_DB_USER}'@'{ADMIN_DB_HOST}';")
        _execute_admin_sql_direct_pymysql("FLUSH PRIVILEGES;", commit=False)
        print(f"SETUP [temporary_test_database]: Executed GRANT (if applicable) and FLUSH PRIVILEGES.")

        # This direct PyMySQL connection as APP_TEST_DB_USER to the new DB works.
        # We will use this knowledge for the SQLAlchemy engine's creator function.
        print(f"DIAGNOSTIC_DIRECT_CONNECT: Verifying direct PyMySQL connection to NEW DB: '{_current_test_db_name}' as user '{APP_TEST_DB_USER}'")
        direct_conn_to_new_db = pymysql.connect(
            host=ADMIN_DB_HOST, user=APP_TEST_DB_USER, password=APP_TEST_DB_PASSWORD,
            database=_current_test_db_name, port=ADMIN_DB_PORT, charset=DB_CHARSET, connect_timeout=10
        )
        with direct_conn_to_new_db.cursor() as cursor:
            cursor.execute("SELECT 1")
            print(f"DIAGNOSTIC_DIRECT_CONNECT: SUCCESS! User '{APP_TEST_DB_USER}' directly connected to '{_current_test_db_name}' and ran SELECT 1.")
        direct_conn_to_new_db.close()

        # Define a creator function for SQLAlchemy engine
        def get_new_db_connection():
            print(f"DEBUG_CREATOR: SQLAlchemy engine 'creator' called. Connecting as '{APP_TEST_DB_USER}' to '{_current_test_db_name}'.")
            return pymysql.connect(
                host=ADMIN_DB_HOST,
                user=APP_TEST_DB_USER,
                password=APP_TEST_DB_PASSWORD,
                database=_current_test_db_name,
                port=ADMIN_DB_PORT,
                charset=DB_CHARSET,
                connect_timeout=10
            )

        # Create SQLAlchemy engine using the custom creator function
        # The URL is still needed for SQLAlchemy to know the dialect, but connection params are from creator
        dummy_url_for_dialect_detection = f"mysql+pymysql://{APP_TEST_DB_USER}:{APP_TEST_DB_PASSWORD}@{ADMIN_DB_HOST}:{ADMIN_DB_PORT}/{_current_test_db_name}"
        
        _test_db_sqlalchemy_engine = create_engine(
            dummy_url_for_dialect_detection, # URL mainly for dialect, actual connection via creator
            creator=get_new_db_connection,
            poolclass=NullPool,
            echo=True # Enable SQLAlchemy logging
        )
        print(f"SETUP [temporary_test_database]: Created SQLAlchemy engine for '{_current_test_db_name}' using custom creator for user '{APP_TEST_DB_USER}'.")

        print(f"SETUP [temporary_test_database]: Attempting to connect with SQLAlchemy engine (via creator) as '{APP_TEST_DB_USER}' to '{_current_test_db_name}' and create tables...")
        with _test_db_sqlalchemy_engine.connect() as conn_check: # This should now work
            print(f"SETUP [temporary_test_database]: SQLAlchemy engine (via creator) connected to '{_current_test_db_name}' as '{APP_TEST_DB_USER}'. Executing SELECT 1...")
            conn_check.execute(text("SELECT 1"))
            print(f"SETUP [temporary_test_database]: Executed 'SELECT 1' on '{_current_test_db_name}'. Creating tables...")
            Base.metadata.create_all(bind=conn_check)
            conn_check.commit()
        print(f"SETUP [temporary_test_database]: Tables created successfully in '{_current_test_db_name}'.")
        
        yield _test_db_sqlalchemy_engine

    except Exception as e:
        if _current_test_db_name:
            print(f"ERROR [temporary_test_database]: Setup failed for '{_current_test_db_name}'. Attempting cleanup. Error: {type(e).__name__}: {e}")
            try:
                _execute_admin_sql_direct_pymysql(f"DROP DATABASE IF EXISTS `{_current_test_db_name}`;")
            except Exception as e_cleanup:
                print(f"ERROR [temporary_test_database]: Cleanup attempt for '{_current_test_db_name}' also failed: {e_cleanup}")
        pytest.fail(f"Failed during temporary_test_database setup for '{_current_test_db_name}': {e}")
    finally:
        if _current_test_db_name:
            print(f"\nTEARDOWN [temporary_test_database]: Attempting to drop temporary test database: {_current_test_db_name} using admin user '{ADMIN_DB_USER}'")
            if _test_db_sqlalchemy_engine:
                _test_db_sqlalchemy_engine.dispose()
                print(f"TEARDOWN [temporary_test_database]: Disposed SQLAlchemy engine for '{_current_test_db_name}'.")
            try:
                _execute_admin_sql_direct_pymysql(f"DROP DATABASE IF EXISTS `{_current_test_db_name}`;")
            except Exception as e_drop:
                print(f"ERROR [temporary_test_database]: Failed to drop test DB '{_current_test_db_name}': {e_drop}")
        _current_test_db_name = None
        _test_db_sqlalchemy_engine = None

# --- db_session and client fixtures (no changes) ---
@pytest.fixture(scope="function")
def db_session(temporary_test_database):
    engine_to_use = temporary_test_database
    connection = engine_to_use.connect()
    transaction = connection.begin()
    ScopedTestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=connection)
    session = ScopedTestingSessionLocal()
    try:
        yield session
    finally:
        session.close()
        transaction.rollback()
        connection.close()

@pytest.fixture(scope="function")
def client(db_session: Session):
    def override_get_db():
        try:
            yield db_session
        finally:
            pass
    app.dependency_overrides[get_db] = override_get_db
    with TestClient(app) as test_client:
        yield test_client
    app.dependency_overrides.clear()