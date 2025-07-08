import os
import json
import hashlib
import subprocess
import time
from pathlib import Path
from typing import Union, Sequence
import re # Import the re module for regular expressions

# --- Base Path Configuration ---
BASE_DIR = Path(__file__).resolve().parent

# --- Configuration ---
ALEMBIC_INI_PATH = BASE_DIR / "alembic.ini"
SQL_DIR = BASE_DIR / "database/sql/triggers"
VERSIONS_DIR = BASE_DIR / "alembic/versions"
STATE_FILE = BASE_DIR / "alembic/.trigger_state.json"

# --- Migration Template ---
# This template is used to generate the content of the Alembic migration file.
# It includes placeholders for revision ID, down revision, creation date,
# and the trigger file name and basename.
MIGRATION_TEMPLATE = """\"\"\"Apply {trigger_name} trigger

Revision ID: {revision_id}
Revises: {down_revision}
Create Date: {create_date}

\"\"\"
from alembic import op
import sqlalchemy as sa
import os

# revision identifiers, used by Alembic.
revision = '{revision_id}'
down_revision = '{down_revision}'
branch_labels = None
depends_on = None

# Construct the path to the SQL trigger file relative to the migration script.
# os.path.dirname(__file__) gets the directory of the current migration script.
# '../../database/sql/triggers/' navigates up two directories and then into the triggers folder.
trigger_file_path = os.path.join(os.path.dirname(__file__), '../../database/sql/triggers/{trigger_name}')

def upgrade():
    # The upgrade function reads the content of the SQL trigger file
    # and executes it, applying the trigger to the database.
    with open(trigger_file_path, 'r') as file:
        op.execute(file.read())

def downgrade():
    # The downgrade function drops the trigger if it exists,
    # reverting the change made by the upgrade.
    op.execute("DROP TRIGGER IF EXISTS {trigger_basename};")
"""

# --- Helper Functions ---

def get_current_alembic_head() -> str:
    """
    Gets the revision ID of the current Alembic head.
    This is used to chain new migrations correctly.
    """
    result = subprocess.run(
        ["alembic", "heads"],
        capture_output=True, text=True, check=True
    )
    lines = result.stdout.strip().splitlines()
    if not lines:
        raise RuntimeError("No Alembic heads found. Ensure Alembic is initialized and migrations exist.")
    # The first line of `alembic heads` output contains the head revision ID.
    return lines[0].split(" ")[0]


def load_state() -> dict:
    """
    Loads the state of processed triggers from the state file.
    This file tracks which triggers have been migrated and their hashes.
    """
    if not STATE_FILE.exists():
        return {}
    with open(STATE_FILE, 'r') as f:
        return json.load(f)


def save_state(state: dict) -> None:
    """
    Saves the current state of processed triggers to the state file.
    """
    with open(STATE_FILE, 'w') as f:
        json.dump(state, f, indent=4)


def generate_revision(trigger_filename: str, message: str):
    """
    Generates a new Alembic revision file using the `alembic revision` command.
    It then parses the output to get the path and revision ID of the newly created file.
    """
    result = subprocess.run(
        ["alembic", "revision", "-m", message],
        capture_output=True, text=True, check=True
    )
    
    # --- DEBUGGING OUTPUT ---
    print("\n--- Alembic 'revision' command raw stdout ---")
    print(result.stdout)
    print("--- End raw stdout ---\n")
    # --- END DEBUGGING OUTPUT ---

    generated_lines = [line for line in result.stdout.splitlines() if 'Generating' in line]
    if not generated_lines:
        raise RuntimeError(f"Could not find generated revision path in Alembic output:\n{result.stdout}")
    
    # Extract the raw path string from Alembic's output.
    # This line is crucial for correctly identifying the file.
    new_revision_path_str_raw = generated_lines[0].split("Generating", 1)[-1].strip()

    # --- FIX: Robustly remove " ... done." from the end of the path string using regex ---
    # Use a regular expression to remove " ... done." or similar trailing patterns
    # This handles potential variations in whitespace before " ... done."
    new_revision_path_str = re.sub(r'\s*\.\.\.\s*done$', '', new_revision_path_str_raw).strip()
    # --- END FIX ---

    # --- DEBUGGING OUTPUT ---
    print(f"DEBUG: Parsed new_revision_path_str (after cleaning): '{new_revision_path_str}'")
    # Convert the string path to a Path object.
    new_revision_path = Path(new_revision_path_str)
    print(f"DEBUG: Path object created: {new_revision_path}")
    print(f"DEBUG: Resolved path (absolute): {new_revision_path.resolve()}")
    # --- END DEBUGGING OUTPUT ---

    # Extract the revision ID from the stem of the filename.
    revision_id = new_revision_path.stem.split('_')[0]
    return new_revision_path, revision_id


def get_file_hash(file_path: Path) -> str:
    """
    Returns a SHA256 hash of the file contents.
    Used to detect changes in SQL trigger files.
    """
    hasher = hashlib.sha256()
    with open(file_path, 'rb') as f:
        # Read file in chunks to handle large files efficiently.
        while chunk := f.read(8192):
            hasher.update(chunk)
    return hasher.hexdigest()


# --- Main Runner ---

def run() -> None:
    """
    Main function to manage trigger migrations.
    It scans the SQL trigger directory, compares file hashes with a stored state,
    and generates new Alembic migrations for new or modified triggers.
    """
    print("--- Running Trigger Migration Manager ---")

    # Ensure the SQL triggers directory exists.
    if not SQL_DIR.exists():
        print(f"SQL directory not found at {SQL_DIR}. Exiting.")
        return

    # Load the state of previously processed triggers.
    processed_triggers = load_state()
    
    # Get the current head revision of Alembic to link new migrations.
    try:
        current_head = get_current_alembic_head()
    except RuntimeError as e:
        print(f"Error getting Alembic head: {e}. Ensure Alembic is initialized (alembic init) and has at least one revision.")
        return

    # Find all SQL files in the triggers directory.
    sql_files = [f for f in SQL_DIR.iterdir() if f.is_file() and f.suffix == '.sql']
    new_migrations_created = False

    for sql_file in sql_files:
        trigger_basename = sql_file.stem # e.g., 'my_trigger_name' from 'my_trigger_name.sql'

        # Check if the trigger has been processed before and if its content has changed.
        if trigger_basename in processed_triggers:
            current_hash = get_file_hash(sql_file)
            stored_hash = processed_triggers[trigger_basename]["hash"]

            if current_hash == stored_hash:
                # If the file hasn't changed, skip to the next one.
                continue

        # If a new or modified trigger file is found, generate a migration.
        print(f"New or modified trigger file found: {sql_file.name}. Generating migration...")
        new_migrations_created = True

        try:
            # Generate a new Alembic revision.
            message = f"Apply trigger {sql_file.name}"
            new_revision_path, revision_id = generate_revision(sql_file.name, message)

            # Format the migration template with dynamic values.
            migration_content = MIGRATION_TEMPLATE.format(
                trigger_name=sql_file.name,
                trigger_basename=trigger_basename,
                revision_id=revision_id,
                down_revision=current_head,
                create_date=time.strftime('%Y-%m-%d %H:%M:%S')
            )

            # Overwrite the newly generated (empty) Alembic migration file
            # with our custom content that applies the SQL trigger.
            with open(new_revision_path, 'w') as f:
                f.write(migration_content)

            print(f"  - Populated migration file: {new_revision_path.name}")

            # Update the state file with the new revision ID and hash for the processed trigger.
            processed_triggers[trigger_basename] = {
                "revision_id": revision_id,
                "hash": get_file_hash(sql_file)
            }
            current_head = revision_id  # Chain this new revision as the `down_revision` for the next.

        except Exception as e:
            # Catch and report any errors during migration generation for a specific file.
            print(f"  !!! Error generating migration for {sql_file.name}: {e}")

    # Save the updated state after all migrations have been processed.
    save_state(processed_triggers)

    if not new_migrations_created:
        print("No new or modified triggers found. Database is up-to-date.")
    else:
        print("--- Migration generation complete. ---")
        print("Review the generated files in alembic/versions/, then run 'alembic upgrade head' to apply.")


if __name__ == "__main__":
    run()