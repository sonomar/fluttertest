from tools.prod.prodTools import extractData
from database.schema.POST.Collectible.collectible_schema import CollectibleCreate
import database.CRUD.POST.Collectible.post_Collectible_CRUD_functions as crudFunctions
from pydantic import ValidationError

def createCollectible(event):
    """
    Adds a new collectible to the database. It validates the request data
    using the CollectibleCreate schema and then calls the corresponding CRUD function.
    """
    data = extractData(event)
    if not data:
        return {'statusCode': 400, 'body': 'Request body is missing'}

    try:
        # Pydantic will automatically validate that all required fields are present.
        # The manual if/else block is no longer necessary.
        collectible_data = CollectibleCreate(**data)
    except ValidationError as e:
        # If the incoming data is invalid, Pydantic raises an error.
        # We catch it and return a detailed 400 Bad Request response.
        return {'statusCode': 400, 'body': e.errors()}

    # Call the CRUD function with the validated Pydantic model.
    # The CRUD function name is also updated to snake_case for consistency.
    return crudFunctions.createCollectible(
        collectible=collectible_data,
        db=event["db_session"]
    )