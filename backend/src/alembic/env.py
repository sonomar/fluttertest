# alembic/env.py
from logging.config import fileConfig

from sqlalchemy import engine_from_config, pool, create_engine, exc, text

from alembic import context

# This is the Alembic Config object, which provides
# access to the values within the .ini file in use.
config = context.config

# Interpret the config file for Python logging.
# This line sets up loggers basically.
if config.config_file_name is not None:
    fileConfig(config.config_file_name)

# add your model's MetaData object here for 'autogenerate' support
# from myapp import mymodel # Example from Alembic template
# target_metadata = mymodel.Base.metadata # Example from Alembic template

# --- CUSTOMIZATION START ---

# Add the parent directory of 'src' to sys.path
# This allows importing modules from 'src'
import sys
import os
# Assuming alembic/env.py is in project_root/alembic/
# We need to add project_root to sys.path
project_root = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
sys.path.insert(0, project_root)

# Now import your Base from src.database (which imports models)
try:
    from database.db import SQLALCHEMY_DATABASE_URL, Base
    print(f"Successfully imported Base from src.database. URL: {SQLALCHEMY_DATABASE_URL}")
except ImportError as e:
    print(SQLALCHEMY_DATABASE_URL)
    print(f"Error importing src.database or models: {e}")
    print("Alembic may not be able to find your models for autogenerate.")
    # Define a dummy Base if import fails, so Alembic can still run (but not autogenerate)
    from sqlalchemy.ext.declarative import declarative_base
    Base = declarative_base()
    SQLALCHEMY_DATABASE_URL = "mysql+pymysql://user:password@host/dbname_dummy" # Dummy URL


# Set target_metadata to the metadata object associated with your Base
target_metadata = Base.metadata

# get the database url from your src.database.py
# This overrides the sqlalchemy.url setting in alembic.ini
config.set_main_option("sqlalchemy.url", SQLALCHEMY_DATABASE_URL)


# --- CUSTOMIZATION END ---


# other values from the config, defined by the needs of env.py,
# can be acquired here by dot notation for the config object.
# my_important_option = config.get_main_option("my_important_option")
# ... etc.


from sqlalchemy import create_engine, exc

def create_db_if_not_exists():
    """Create the database if it doesn't exist for MySQL."""
    db_uri = SQLALCHEMY_DATABASE_URL
    database = db_uri.split('/')[-1]
    db_mysql = "/".join(db_uri.split('/')[0:-1]) + "/information_schema"  # Connect to 'information_schema' database

    try:
        # Attempt to connect to the target database
        engine = create_engine(db_uri)
        with engine.connect() as conn:
            print(f"Database '{database}' already exists.")
    except exc.OperationalError:
        # If connection fails, check if the database exists
        print(f"Database '{database}' does not exist. Creating now.")
        engine = create_engine(db_mysql)
        with engine.connect() as conn:
            result = conn.execute(text(f"SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = '{database}'"))
            if result.fetchone():
                print(f"Database '{database}' already exists in MySQL.")
            else:
                conn.execute(text(f"CREATE DATABASE `{database}`;"))
                print(f"Database '{database}' created successfully.")



create_db_if_not_exists()  # Ensure the database exists before migrating


def run_migrations_offline():
    """Run migrations in 'offline' mode.

    This configures the context with just a URL
    and not an Engine, though an Engine is acceptable
    here as well.  By skipping the Engine creation
    we don't even need a database to begin with.

    Calls to context.execute() here correspond to the
    autogenerated scripts.

    When invoked via the command line, this will typically
    generate per-dialect conditional code for tables.
    """
    # url = config.get_main_option("sqlalchemy.url") # <-- Use the URL set above
    url = context.get_bind().url # Get the URL from the context, which got it from config

    context.configure(
        url=url,
        target_metadata=target_metadata,
        literal_binds=True,
        dialect_opts={"paramstyle": "named"},
    )

    with context.begin_transaction():
        context.run_migrations()


def run_migrations_online():
    """Run migrations in 'online' mode.

    In this scenario we need to create an Engine
    and associate a connection with the context.

    """
    # connectable = engine_from_config( # <-- Use the URL set in config
    #     config.get_section(config.config_ini_section),
    #     prefix="sqlalchemy.",
    #     poolclass=pool.NullPool,
    # )
    connectable = context.get_bind() # Get the engine from the context, which got the URL from config

    
    context.configure(
        connection=connectable,
        target_metadata=target_metadata
    )

    with context.begin_transaction():
        context.run_migrations()

# Determine if running online or offline (usually handled by Alembic command)
if context.is_offline_mode():
    run_migrations_offline()
else:
    # To support running online, we need a live engine.
    # Get the URL from the config which we populated from src.database
    db_url = config.get_main_option("sqlalchemy.url")
    if not db_url or "dummy" in db_url: # Check if URL is valid
         print("Database URL is not configured properly. Cannot run online migrations.")
         # Exit or handle error
         sys.exit(1) # Exit if online mode cannot connect

    # Create the engine for online mode
    online_connectable = engine_from_config(
         config.get_section(config.config_ini_section),
         prefix="sqlalchemy.",
         poolclass=pool.NullPool,
         url=db_url # Explicitly pass the determined URL
    )
    context.configure(
         connection=online_connectable.connect(), # Provide a connection
         target_metadata=target_metadata,
    )
    run_migrations_online() # Now run online