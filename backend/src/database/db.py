# src/database.py
import os
import logging
from typing import Generator


from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, Session, DeclarativeBase
from sqlalchemy.ext.declarative import declarative_base # Needed for Alembic target_metadata

# We'll import the Base from models.py later, but define it here first
# as a placeholder that Alembic env.py can point to initially.
# It will be overridden by the import from models.py
Base = declarative_base()

# The Base class is now imported from src.database, remove its definition here
class Base(DeclarativeBase): # <-- REMOVED
     pass # <-- REMOVED

# --- Database URL Configuration ---
# This adapts to your environment (local via .env, prod via Secrets Manager)

def get_db_url():
    """Retrieves the database connection URL based on environment."""
    # Assuming 'production' env uses AWS Secrets Manager
    if os.environ.get('ENV') == 'production':
        # This part needs to replicate the logic from tools.prod.prodTools.get_secrets()
        # Or, better, import and use it directly if possible and clean.
        # For now, let's assume get_secrets exists and returns a dict
        from tools.prod.prodTools import get_secrets # Adjust import path if necessary
        parameters = get_secrets() # This will fetch from Secrets Manager in prod

        # Construct URL from secrets
        db_host = parameters.get('DB_HOST')
        db_port = parameters.get('DB_PORT', 3306) # Default MySQL port
        db_user = parameters.get('DB_USER')
        db_password = parameters.get('DB_PASSWORD')
        db_name = parameters.get('DB_NAME')

        # Using pymysql driver (mysql+pymysql)
        # If you stick with pymysql, use mysql+pymysql://
        return f"mysql+pymysql://{db_user}:{db_password}@{db_host}:{db_port}/{db_name}"
    else:
        # Local development - use environment variables (e.g., from .env)
        # Assuming you have a .env file loaded elsewhere (like in main.py startup)
        from dotenv import load_dotenv
        load_dotenv()
        db_host = os.environ.get('DB_HOST')
        db_port = os.environ.get('DB_PORT', 3306)
        db_user = os.environ.get('DB_USER')
        db_password = os.environ.get('DB_PASSWORD')
        db_name = os.environ.get('DB_NAME')

        if not all([db_host, db_user, db_password, db_name]):
             logging.error("Database environment variables are not set!")
             # Handle this error appropriately - maybe raise an exception
             # In local FastAPI, this might prevent startup
             # In Lambda, this might cause an error on first connection attempt
             # For now, let's return None or an incomplete URL
             return None # Or raise ValueError

        return f"mysql+pymysql://{db_user}:{db_password}@{db_host}:{db_port}/{db_name}"


SQLALCHEMY_DATABASE_URL = get_db_url()

if not SQLALCHEMY_DATABASE_URL:
     # Handle the case where URL could not be generated
     # In a production FastAPI app, you might want to exit or raise on startup
     # For this flexible setup, just log the error and connections will fail
     logging.error("Failed to generate database URL.")
     # Set to a dummy value to allow app to potentially start, but DB operations will fail
     SQLALCHEMY_DATABASE_URL = "mysql+pymysql://user:password@host/dbname_dummy"


# --- SQLAlchemy Engine and Session ---

# The engine is the starting point for SQLAlchemy
# It is created once per application lifetime
engine = create_engine(
    SQLALCHEMY_DATABASE_URL,
    pool_pre_ping=True # Helps prevent "MySQL server has gone away" issues
    # Other options like pool_size, max_overflow may be needed depending on load
)

# SessionLocal is a factory to create Session objects
# Each Session is a transaction scope
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# --- Dependency to get a DB session ---

def get_db() -> Generator[Session, None, None]:
    """Provides a SQLAlchemy session to FastAPI endpoints."""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# --- Import Models ---
# Import your models here after Base is defined, so they can register with Base.metadata
# This avoids circular imports if models need to import Base.
from database.models import * # Adjust import path if models.py is not directly in src

# Now, the Base variable defined *before* is effectively replaced by the Base
# imported from models.py, ensuring all models are linked to the correct metadata.
# We could also just import `Base` from `models` initially if `models` doesn't
# depend on `database` during its definition phase.
# Given your `models.py` structure seems standalone, let's adjust to import Base directly:
# from models import Base # Uncomment and use this if your models.py correctly defines Base

# If models.py *was* generated assuming Base is defined elsewhere, keep the initial Base definition
# and the 'from models import *' style import. The original code implies Base is in models.py,
# so importing Base directly is cleaner. Let's use that:

try:
    # Attempt to import Base directly from models.py
    from database.models import Base
    logging.info("Successfully imported Base from models.py")
except ImportError:
    logging.error("Could not import Base from models.py. Ensure models.py is in the path and defines 'Base'.")
    # Fallback to the locally defined Base, but this likely means Alembic won't find your tables
    pass # Keep the locally defined Base if import fails

# --- Helper for creating all tables (mainly for initial dev, use migrations generally) ---
# DO NOT use this in production with Alembic enabled, migrations are the source of truth.
def create_all_tables():
    logging.info("Attempting to create all database tables...")
    try:
        Base.metadata.create_all(bind=engine)
        logging.info("Database tables created successfully (if they didn't exist).")
    except Exception as e:
        logging.error(f"Error creating database tables: {e}")