from tools.prod.prodTools import extractData
import database.CRUD.PATCH.Collectible.patch_Collectible_CRUD_functions as crudFunctions
from database.schema.PATCH.Collectible.collectible_schema import CollectibleUpdate
from pydantic import ValidationError

def updateCollectibleByCollectibleId(event):
    """
    Updates an existing Collectible. It extracts data from the event, validates it
    using the CollectibleUpdate schema, and calls the CRUD function to update the database.
    """
    data = extractData(event)
    if not data or "collectibleId" not in data:
        return {'statusCode': 400, 'body': 'collectibleId is required in the request body'}

    collectible_id = data.pop("collectibleId")

    try:
        # Pydantic will automatically validate and parse the incoming data.
        # The manual CollectibleDataCheck function is no longer needed.
        collectible_update_data = CollectibleUpdate(**data)
    except ValidationError as e:
        # If the data is invalid, return a 400 error with specific details.
        return {'statusCode': 400, 'body': e.errors()}

    return crudFunctions.updateCollectibleByCollectibleId(
        collectibleId=collectible_id,
        collectible_update_data=collectible_update_data, 
        db=event['db_session']
    )