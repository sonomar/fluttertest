# database/CRUD/POST/Collection/post_Collection_table.py
from tools.prod.prodTools import extractData, get_connection
from database.schema.POST.Collection.collection_schema import CollectionCreate
import database.CRUD.POST.Collection.post_Collection_CRUD_functions as crudFunctions

def create_collection(event):
    """
    Adds a new collection to the database.
    Requires 'communityId', 'name'. Other fields are optional.
    """
    data = extractData(event)

    # Basic validation for required fields
    if not data or "communityId" not in data or "name" not in data:
        return {
            "statusCode": 400,
            "body": "communityId and name are required"
        }

    # Create Pydantic model instance
    # Use .get() for optional fields with default values from schema
    collection = CollectionCreate(
        communityId=data["communityId"],
        name=data["name"],
        description=data.get("description"),
        imageRef=data.get("imageRef"),
        vidRef=data.get("vidRef"),
        qrRef=data.get("qrRef"),
        embedRef=data.get("embedRef"),
        active=data.get("active") # Schema default is True if not provided
    )

    # Call the CRUD function with the Pydantic model and DB session
    # Assumes event["db_session"] contains the SQLAlchemy session
    return crudFunctions.create_collection(collection=collection, db=event["db_session"])

