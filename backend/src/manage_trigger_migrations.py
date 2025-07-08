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

# --- Templates for injecting into Alembic's default migration file ---
# These templates define only the *body* of the upgrade and downgrade functions.
# They will be injected into the existing Alembic-generated file.
UPGRADE_BODY_TEMPLATE = """
    # If this trigger was altered, drop the existing one before creating the new version.
    {drop_existing_trigger_sql}
    # The upgrade function reads the content of the SQL trigger file
    # and executes it, applying the trigger to the database.
    with open(trigger_file_path, 'r') as file:
        op.execute(file.read())
"""

DOWNGRADE_BODY_TEMPLATE = """
    op.execute("DROP TRIGGER IF EXISTS {trigger_basename};")
"""

# --- Helper Functions ---

def get_current_alembic_head() -> Union[str, None]:
    """
    Gets the revision ID of the current Alembic head.
    Returns None if no heads are found (e.g., a fresh Alembic environment),
    otherwise returns the head revision ID as a string.
    Handles CalledProcessError if 'alembic heads' command fails.
    """
    try:
        result = subprocess.run(
            ["alembic", "heads"],
            capture_output=True, text=True, check=True,
            cwd=BASE_DIR # Ensure alembic command runs from the base directory
        )
        lines = result.stdout.strip().splitlines()
        if not lines:
            # This case should ideally be caught by CalledProcessError if alembic exits with 1,
            # but as a fallback, if stdout is empty but no error was raised.
            return None
        return lines[0].split(" ")[0]
    except subprocess.CalledProcessError as e:
        # If 'alembic heads' returns non-zero, it often means no heads exist.
        # Check stderr for specific messages or assume no heads if stdout is empty.
        # Alembic heads typically returns exit status 1 if no heads are found.
        if "No heads found" in e.stderr or not e.stdout.strip():
            print("INFO: No Alembic heads found. This is likely a fresh environment.")
            return None
        else:
            # Re-raise if it's a different kind of error (e.g., alembic not installed/in PATH)
            raise RuntimeError(f"Alembic 'heads' command failed unexpectedly: {e.stderr}") from e
    except Exception as e:
        # Catch any other unexpected errors
        raise RuntimeError(f"An unexpected error occurred while getting Alembic head: {e}") from e


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
        capture_output=True, text=True, check=True,
        cwd=BASE_DIR # Ensure alembic command runs from the base directory
    )
    
    # --- DEBUGGING OUTPUT ---
    print("\n--- Alembic 'revision' command raw stdout ---")
    print(result.stdout)
    print("--- End raw stdout ---\n")
    # --- END DEBUGGING OUTPUT ---

    # Search for the pattern "Generating <path> ... done" where <path> can span multiple lines
    # and might contain spaces.
    # We'll capture the path part.
    path_pattern = re.compile(r"Generating\s+(.*?)(?:\s*\.\.\.\s*done)?$", re.DOTALL)
    match = path_pattern.search(result.stdout)

    if not match:
        raise RuntimeError(f"Could not find generated revision path in Alembic output:\n{result.stdout}")
    
    # The captured group (1) will contain the raw path string, potentially with newlines and extra spaces.
    new_revision_path_str_raw = match.group(1)
    
    # --- FIX: Robust string cleaning for the path ---
    # 1. Remove all newline characters.
    cleaned_path = new_revision_path_str_raw.replace('\n', '')
    # 2. Condense any sequence of whitespace characters (including those that replaced newlines) into a single space.
    cleaned_path = re.sub(r'\s+', ' ', cleaned_path)
    # 3. Strip leading/trailing whitespace.
    new_revision_path_str = cleaned_path.strip()
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
    print(f"DEBUG: Extracted revision ID: '{revision_id}'") # Added debug for revision_id
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
    current_head = get_current_alembic_head()

    # Find all SQL files in the triggers directory.
    sql_files = [f for f in SQL_DIR.iterdir() if f.is_file() and f.suffix == '.sql']
    new_migrations_created = False

    for sql_file in sql_files:
        trigger_basename = sql_file.stem # e.g., 'my_trigger_name' from 'my_trigger_name.sql'
        
        # Initialize drop_existing_trigger_sql for the template
        # This will be an empty string if the trigger is new or unchanged,
        # otherwise it will contain the DROP statement.
        drop_existing_trigger_sql = "" 

        # Check if the trigger has been processed before and if its content has changed.
        if trigger_basename in processed_triggers:
            current_hash = get_file_hash(sql_file)
            stored_hash = processed_triggers[trigger_basename]["hash"]

            if current_hash == stored_hash:
                # If the file hasn't changed, skip to the next one.
                continue
            else:
                # Trigger has been altered, include a DROP statement in the new migration's upgrade.
                # This ensures the old trigger is dropped before the new one is created.
                drop_existing_trigger_sql = f"op.execute(\"DROP TRIGGER IF EXISTS {trigger_basename};\")"
        
        # If a new or modified trigger file is found, generate a migration.
        print(f"New or modified trigger file found: {sql_file.name}. Generating migration...")
        new_migrations_created = True

        try:
            # Generate a new Alembic revision.
            message = f"Apply trigger {sql_file.name}"
            new_revision_path, revision_id = generate_revision(sql_file.name, message)

            # --- Read the content of the newly generated (empty) Alembic migration file ---
            with open(new_revision_path, 'r') as f:
                migration_file_content = f.read()

            # --- Prepare the upgrade and downgrade body content ---
            upgrade_body = UPGRADE_BODY_TEMPLATE.format(
                drop_existing_trigger_sql=drop_existing_trigger_sql
            )
            downgrade_body = DOWNGRADE_BODY_TEMPLATE.format(
                trigger_basename=trigger_basename
            )
            
            # --- Inject the content into the upgrade and downgrade functions using regex ---
            # Pattern to match 'def upgrade() -> None: ... pass'
            upgrade_pattern = r'(def upgrade\(\) -> None:\s*"""Upgrade schema\."""\s*)pass'
            migration_file_content = re.sub(
                upgrade_pattern,
                r'\1' + upgrade_body.strip(), # \1 refers to the captured group (the function definition and docstring)
                migration_file_content,
                count=1,
                flags=re.DOTALL # Allow '.' to match newlines for multi-line docstrings
            )

            # Pattern to match 'def downgrade() -> None: ... pass'
            downgrade_pattern = r'(def downgrade\(\) -> None:\s*"""Downgrade schema\."""\s*)pass'
            migration_file_content = re.sub(
                downgrade_pattern,
                r'\1' + downgrade_body.strip(),
                migration_file_content,
                count=1,
                flags=re.DOTALL
            )

            # --- Dynamically update other parts of the migration file ---
            # Update revision ID
            migration_file_content = re.sub(
                r"revision: str = '.*'",
                f"revision: str = '{revision_id}'",
                migration_file_content,
                count=1
            )
            # Update down_revision
            # Format down_revision for the template: 'None' if current_head is None, else "'<revision_id>'"
            # This line needs to be *inside* the loop to use the updated current_head
            template_down_revision_val = 'None' if current_head is None else f"'{current_head}'"
            migration_file_content = re.sub(
                r"down_revision: Union\[str, None\] = .*", # Match anything after '='
                f"down_revision: Union[str, None] = {template_down_revision_val}",
                migration_file_content,
                count=1
            )
            
            # Update Create Date in the docstring and potentially in the file
            # Update the initial docstring message
            docstring_new_content = (
                f"Apply {sql_file.name} trigger\n\n"
                f"Revision ID: {revision_id}\n"
                f"Revises: {current_head if current_head is not None else 'None'}\n" # Use actual current_head for docstring
                f"Create Date: {time.strftime('%Y-%m-%d %H:%M:%S')}"
            )
            
            # Replace the content within the triple quotes (the main docstring)
            migration_file_content = re.sub(
                r'"""\s*.*?Revision ID:.*?Create Date:.*?"""', # Matches the entire docstring block
                f'"""{docstring_new_content}\n\n"""', # Recreate with new content, adding newlines for formatting
                migration_file_content,
                count=1,
                flags=re.DOTALL
            )

            # Ensure 'import os' is present for os.path.join
            if "import os" not in migration_file_content:
                migration_file_content = migration_file_content.replace(
                    "import sqlalchemy as sa",
                    "import sqlalchemy as sa\nimport os"
                )

            # Insert trigger_file_path definition after depends_on = None
            trigger_path_definition = f"trigger_file_path = os.path.join(os.path.dirname(__file__), '../../database/sql/triggers/{sql_file.name}')"
            
            # Find the line 'depends_on: Union[str, Sequence[str], None] = None' and insert after it
            migration_file_content = re.sub(
                r"(depends_on: Union\[str, Sequence\[str\], None\] = None\s*)",
                r"\1\n\n" + trigger_path_definition + "\n",
                migration_file_content,
                count=1
            )

            # --- Write the modified content back to the file ---
            with open(new_revision_path, 'w') as f:
                f.write(migration_file_content)

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
    print(f"DEBUG: State to be saved to {STATE_FILE.name}: {json.dumps(processed_triggers, indent=4)}") # Added debug for state
    save_state(processed_triggers)

    if not new_migrations_created:
        print("No new or modified triggers found. Database is up-to-date.")
    else:
        print("--- Migration generation complete. ---")
        print("Review the generated files in alembic/versions/, then run 'alembic upgrade head' to apply.")


if __name__ == "__main__":
    run()