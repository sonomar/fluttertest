# database/CRUD/POST/Collectible/post_Collectible_table.py
from tools.prod.prodTools import extractData
from database.schema.POST.Collectible.collectible_schema import CollectibleCreate
import database.CRUD.POST.Collectible.post_Collectible_CRUD_functions as crudFunctions

def create_collectible(event):
    """
    Adds a new collectible to the database.
    Requires 'collectionId', 'categoryId', 'projectId', 'communityId', 'label', 'name'.
    Other fields are optional.
    """
    data = extractData(event)

    # Basic validation for required fields
    if not data or "collectionId" not in data or "categoryId" not in data or \
       "projectId" not in data or "communityId" not in data or "label" not in data or \
       "name" not in data:
        return {
            "statusCode": 400,
            "body": "collectionId, categoryId, projectId, communityId, label, and name are required"
        }

    # Create Pydantic model instance
    collectible = CollectibleCreate(
        collectionId=data["collectionId"],
        categoryId=data["categoryId"],
        projectId=data["projectId"],
        communityId=data["communityId"],
        label=data["label"],
        name=data["name"],
        description=data.get("description"),
        imageRef=data.get("imageRef"),
        vidRef=data.get("vidRef"),
        qrRef=data.get("qrRef"),
        embedRef=data.get("embedRef"),
        circulation=data.get("circulation"),
        publicationDate=data.get("publicationDate"),
        active=data.get("active") # Schema default is True if not provided
    )

    # Call the CRUD function with the Pydantic model and DB session
    # Assumes event["db_session"] contains the SQLAlchemy session
    return crudFunctions.create_collectible(collectible=collectible, db=event["db_session"])