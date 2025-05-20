# database/CRUD/POST/Community/post_Community_table.py
from tools.prod.prodTools import extractData
from database.schema.POST.Community.community_schema import CommunityCreate
import database.CRUD.POST.Community.post_Community_CRUD_functions as crudFunctions

def create_community(event):
    """
    Adds a new community to the database.
    Requires 'title'. Other fields are optional.
    """
    data = extractData(event)

    # Basic validation for required fields
    if not data or "title" not in data:
        return {
            "statusCode": 400,
            "body": "title is required"
        }

    # Create Pydantic model instance
    community = CommunityCreate(
        title=data["title"],
        description=data.get("description"),
        imageRef=data.get("imageRef"),
        vidRef=data.get("vidRef"),
        qrRef=data.get("qrRef"),
        embedRef=data.get("embedRef"),
        active=data.get("active") # Schema default is True if not provided
    )

    # Call the CRUD function with the Pydantic model and DB session
    # Assumes event["db_session"] contains the SQLAlchemy session
    return crudFunctions.create_community(community=community, db=event["db_session"])

