import os
import json
import hashlib
import subprocess
import time
import argparse
from pathlib import Path
from typing import Union, Sequence
import re

# --- Base Path Configuration ---
BASE_DIR = Path(__file__).resolve().parent

# --- Configuration ---
ALEMBIC_INI_PATH = BASE_DIR / "alembic.ini"
SQL_DIR = BASE_DIR / "database/sql/triggers"
VERSIONS_DIR = BASE_DIR / "alembic/versions"
STATE_FILE = BASE_DIR / "alembic/.trigger_state.json"

# --- Templates ---
UPGRADE_BODY_TEMPLATE = """
    {drop_existing_trigger_sql}
    with open(trigger_file_path, 'r') as file:
        op.execute(file.read())
"""

DOWNGRADE_BODY_TEMPLATE = """
    op.execute("DROP TRIGGER IF EXISTS {trigger_basename};")
"""

# --- Logging Helper ---
def log(message, level="INFO"):
    print(f"[{level}] {message}")

# --- Helper Functions ---

def get_current_alembic_head() -> Union[str, None]:
    try:
        result = subprocess.run(
            ["alembic", "heads"],
            capture_output=True, text=True, check=True,
            cwd=BASE_DIR
        )
        lines = result.stdout.strip().splitlines()
        return lines[0].split(" ")[0] if lines else None
    except subprocess.CalledProcessError as e:
        if "No heads found" in e.stderr or not e.stdout.strip():
            log("No Alembic heads found. This is likely a fresh environment.")
            return None
        raise RuntimeError(f"Alembic 'heads' failed: {e.stderr}") from e

def load_state() -> dict:
    return json.loads(STATE_FILE.read_text()) if STATE_FILE.exists() else {}

def save_state(state: dict) -> None:
    STATE_FILE.write_text(json.dumps(state, indent=4))

def get_file_hash(file_path: Path) -> str:
    hasher = hashlib.sha256()
    with open(file_path, 'rb') as f:
        while chunk := f.read(8192):
            hasher.update(chunk)
    return hasher.hexdigest()

def get_latest_revision_file() -> Path:
    version_files = list(VERSIONS_DIR.glob("*.py"))
    if not version_files:
        raise RuntimeError("No Alembic revision files found.")
    return max(version_files, key=os.path.getmtime)

def validate_trigger_filename(name: str) -> bool:
    return re.fullmatch(r'[a-zA-Z0-9_]+', name) is not None

def generate_revision(trigger_filename: str, message: str):
    subprocess.run(
        ["alembic", "revision", "-m", message],
        capture_output=True, text=True, check=True,
        cwd=BASE_DIR
    )

    new_revision_path = get_latest_revision_file()
    revision_id = new_revision_path.stem.split('_')[0]
    return new_revision_path, revision_id

# --- Main Logic ---

def run():
    log("Running Trigger Migration Manager")

    if not SQL_DIR.exists():
        log(f"SQL directory not found at {SQL_DIR}. Exiting.", "ERROR")
        return

    processed_triggers = load_state()
    current_head = get_current_alembic_head()
    sql_files = [f for f in SQL_DIR.iterdir() if f.is_file() and f.suffix == '.sql']
    new_migrations_created = False

    for sql_file in sql_files:
        trigger_basename = sql_file.stem

        if not validate_trigger_filename(trigger_basename):
            log(f"Invalid trigger filename: {sql_file.name}. Skipping.", "WARNING")
            continue

        drop_existing_trigger_sql = f'op.execute("DROP TRIGGER IF EXISTS {trigger_basename};")'
        current_hash = get_file_hash(sql_file)
        stored = processed_triggers.get(trigger_basename)

        if stored and current_hash == stored["hash"]:
            continue

        log(f"New or modified trigger found: {sql_file.name}. Generating migration...")
        new_migrations_created = True

        try:
            message = f"Apply trigger {sql_file.name}"
            new_revision_path, revision_id = generate_revision(sql_file.name, message)

            with open(new_revision_path, 'r') as f:
                content = f.read()

            upgrade_body = UPGRADE_BODY_TEMPLATE.format(
                drop_existing_trigger_sql=drop_existing_trigger_sql
            ).strip()

            downgrade_body = DOWNGRADE_BODY_TEMPLATE.format(
                trigger_basename=trigger_basename
            ).strip()

            # Inject upgrade
            content = re.sub(
                r'(def upgrade\(\) -> None:\s*"""Upgrade schema\."""\s*)pass',
                r'\1' + upgrade_body,
                content, count=1, flags=re.DOTALL
            )

            # Inject downgrade
            content = re.sub(
                r'(def downgrade\(\) -> None:\s*"""Downgrade schema\."""\s*)pass',
                r'\1' + downgrade_body,
                content, count=1, flags=re.DOTALL
            )

            content = re.sub(
                r"revision: str = '.*'",
                f"revision: str = '{revision_id}'",
                content, count=1
            )

            template_down_revision = 'None' if current_head is None else f"'{current_head}'"
            content = re.sub(
                r"down_revision: Union\[str, None\] = .*",
                f"down_revision: Union[str, None] = {template_down_revision}",
                content, count=1
            )

            docstring = (
                f"Apply {sql_file.name} trigger\n\n"
                f"Revision ID: {revision_id}\n"
                f"Revises: {current_head or 'None'}\n"
                f"Create Date: {time.strftime('%Y-%m-%d %H:%M:%S')}\n\n"
            )
            content = re.sub(
                r'""".*?Revision ID:.*?Create Date:.*?"""',
                f'"""{docstring}"""',
                content, flags=re.DOTALL
            )

            if "import os" not in content:
                content = content.replace(
                    "import sqlalchemy as sa",
                    "import sqlalchemy as sa\nimport os"
                )

            trigger_path_definition = f"trigger_file_path = os.path.join(os.path.dirname(__file__), '../../database/sql/triggers/{sql_file.name}')"
            content = re.sub(
                r"(depends_on: Union\[str, Sequence\[str\], None\] = None\s*)",
                r"\1\n" + trigger_path_definition + "\n",
                content, count=1
            )

            with open(new_revision_path, 'w') as f:
                f.write(content)

            log(f"Populated migration file: {new_revision_path.name}")
            processed_triggers[trigger_basename] = {
                "revision_id": revision_id,
                "hash": current_hash
            }
            current_head = revision_id

        except Exception as e:
            log(f"Error generating migration for {sql_file.name}: {e}", "ERROR")

    save_state(processed_triggers)
    if new_migrations_created:
        log("Migration generation complete.")
        log("Review generated files in alembic/versions/, then run: alembic upgrade head")
    else:
        log("No new or modified triggers. Database is up-to-date.")

# --- CLI Interface ---

def main():
    parser = argparse.ArgumentParser(description="Trigger Migration Manager")
    parser.add_argument("--reset", action="store_true", help="Clear saved trigger state (use with caution)")
    parser.add_argument("--debug-state", action="store_true", help="Print current trigger state and exit")
    args = parser.parse_args()

    if args.reset:
        STATE_FILE.unlink(missing_ok=True)
        log("Trigger state file reset.")
        return

    if args.debug_state:
        state = load_state()
        log(json.dumps(state, indent=4), "STATE")
        return

    run()

if __name__ == "__main__":
    main()