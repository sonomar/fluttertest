import os
import json
import subprocess
import time
from pathlib import Path

# --- Configuration ---
# Path to your alembic.ini file
ALEMBIC_INI_PATH = "alembic.ini"
# Directory where your .sql trigger files are stored
SQL_DIR = Path("src/database/sql/triggers")
# Path to the Alembic versions directory
VERSIONS_DIR = Path("alembic/versions")
# State file to track which triggers have been migrated
STATE_FILE = Path("alembic/.trigger_state.json")

# Template for the auto-generated migration files
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

trigger_file_path = os.path.join(os.path.dirname(__file__), '../../src/database/sql/triggers/{trigger_name}')

def upgrade():
    with open(trigger_file_path, 'r') as file:
        # Execute the entire SQL file, which includes DROP and CREATE
        op.execute(file.read())

def downgrade():
    # The downgrade is simple: just drop the trigger.
    op.execute("DROP TRIGGER IF EXISTS {trigger_basename};")

"""

def get_current_alembic_head():
    """Gets the revision ID of the current Alembic head."""
    result = subprocess.run(
        ["alembic", "heads"],
        capture_output=True, text=True, check=True
    )
    return result.stdout.strip().split(" ")[0]

def load_state():
    """Loads the state of processed triggers from the state file."""
    if not STATE_FILE.exists():
        return {}
    with open(STATE_FILE, 'r') as f:
        return json.load(f)

def save_state(state):
    """Saves the state of processed triggers."""
    with open(STATE_FILE, 'w') as f:
        json.dump(state, f, indent=4)

def run():
    """Main function to generate migrations for new triggers."""
    print("--- Running Trigger Migration Manager ---")
    
    if not SQL_DIR.exists():
        print(f"SQL directory not found at {SQL_DIR}. Exiting.")
        return

    processed_triggers = load_state()
    current_head = get_current_alembic_head()
    
    sql_files = [f for f in SQL_DIR.iterdir() if f.is_file() and f.suffix == '.sql']

    new_migrations_created = False
    for sql_file in sql_files:
        if sql_file.name in processed_triggers:
            continue
            
        new_migrations_created = True
        trigger_basename = sql_file.stem
        print(f"New trigger file found: {sql_file.name}. Generating migration...")

        # 1. Generate a new Alembic revision
        message = f"Apply trigger {sql_file.name}"
        result = subprocess.run(
            ["alembic", "revision", "-m", message],
            capture_output=True, text=True, check=True
        )
        
        # Extract the new revision file path from the output
        # Alembic output is typically "Generating /path/to/versions/rev_id_message.py"
        new_revision_path_str = [line for line in result.stdout.splitlines() if 'Generating' in line][0].split(' ')[1]
        new_revision_path = Path(new_revision_path_str)
        revision_id = new_revision_path.stem.split('_')[0]
        
        print(f"  - Generated revision: {revision_id}")

        # 2. Populate the new migration file with our template
        migration_content = MIGRATION_TEMPLATE.format(
            trigger_name=sql_file.name,
            trigger_basename=trigger_basename,
            revision_id=revision_id,
            down_revision=current_head,
            create_date=time.strftime('%Y-%m-%d %H:%M:%S')
        )
        
        with open(new_revision_path, 'w') as f:
            f.write(migration_content)
        
        print(f"  - Populated migration file: {new_revision_path.name}")
        
        # 3. Update state
        processed_triggers[sql_file.name] = revision_id
        current_head = revision_id # The next migration will depend on this one
        
    save_state(processed_triggers)
    
    if not new_migrations_created:
        print("No new triggers found. Database is up-to-date.")
    else:
        print("--- Migration generation complete. ---")
        print("Review the generated files in alembic/versions/, then run 'alembic upgrade head' to apply.")

if __name__ == "__main__":
    run()