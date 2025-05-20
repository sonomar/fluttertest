# database/CRUD/POST/Project/post_Project_table.py
from tools.prod.prodTools import extractData
from database.schema.POST.Project.project_schema import ProjectCreate
import database.CRUD.POST.Project.post_Project_CRUD_functions as crudFunctions

def create_project(event):
    """
    Adds a new project to the database.
    Requires 'name', 'attributed'. 'location' and 'active' are optional.
    """
    data = extractData(event)

    # Basic validation for required fields
    if not data or "name" not in data or "attributed" not in data:
        return {
            "statusCode": 400,
            "body": "name and attributed are required"
        }

    # Create Pydantic model instance
    project = ProjectCreate(
        name=data["name"],
        attributed=data["attributed"],
        location=data.get("location"),
        active=data.get("active") # Schema default is True if not provided
    )

    # Call the CRUD function with the Pydantic model and DB session
    # Assumes event["db_session"] contains the SQLAlchemy session
    return crudFunctions.create_project(project=project, db=event["db_session"])