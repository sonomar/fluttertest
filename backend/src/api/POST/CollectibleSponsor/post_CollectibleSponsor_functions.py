# database/CRUD/POST/CollectibleSponsor/post_CollectibleSponsor_table.py
from tools.prod.prodTools import extractData, get_connection
from database.schema.POST.CollectibleSponsor.collectibleSponsor_schema import CollectibleSponsorCreate
import database.CRUD.POST.CollectibleSponsor.post_CollectibleSponsor_CRUD_functions as crudFunctions

def createCollectibleSponsor(event):
    """
    Adds a new collectible sponsor entry to the database.
    Requires 'collectibleId', 'sponsorId'. 'sponsorMessage' and 'active' are optional.
    """
    data = extractData(event)

    # Basic validation for required fields
    if not data or "collectibleId" not in data or "sponsorId" not in data:
        return {
            "statusCode": 400,
            "body": "collectibleId and sponsorId are required"
        }

    # Create Pydantic model instance
    collectible_sponsor = CollectibleSponsorCreate(
        collectibleId=data["collectibleId"],
        sponsorId=data["sponsorId"],
        sponsorMessage=data.get("sponsorMessage"),
        active=data.get("active") # Schema default is True if not provided
    )

    # Call the CRUD function with the Pydantic model and DB session
    # Assumes event["db_session"] contains the SQLAlchemy session
    return crudFunctions.createCollectibleSponsor(collectible_sponsor=collectible_sponsor, db=event["db_session"])