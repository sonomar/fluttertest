# database/CRUD/POST/UserCollectible/post_UserCollectible_table.py
from tools.prod.prodTools import extractData
from database.schema.POST.UserCollectible.userCollectible_schema import UserCollectibleCreate
import database.CRUD.POST.UserCollectible.post_UserCollectible_CRUD_functions as crudFunctions

def createUserCollectible(event):
    """
    Adds a new user collectible entry to the database.
    Requires 'ownerId', 'collectibleId', 'mint'. Other fields are optional.
    """
    data = extractData(event)

    # Basic validation for required fields
    if not data or "ownerId" not in data or "collectibleId" not in data or "mint" not in data:
        return {
            "statusCode": 400,
            "body": "ownerId, collectibleId, and mint are required"
        }

    # Create Pydantic model instance
    user_collectible = UserCollectibleCreate(
        ownerId=data["ownerId"],
        collectibleId=data["collectibleId"],
        mint=data["mint"],
        previousOwnerId=data.get("previousOwnerId"),
        lastTransferredDt=data.get("lastTransferredDt"),
        active=data.get("active"), # Schema default is True if not provided
        favorite=data.get("favorite") # Schema default is False if not provided
    )

    # Call the CRUD function with the Pydantic model and DB session
    # Assumes event["db_session"] contains the SQLAlchemy session
    return crudFunctions.createUserCollectible(user_collectible=user_collectible, db=event["db_session"])