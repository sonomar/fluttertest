# database/CRUD/GET/Collectible/get_Collectible_table.py
from tools.prod.prodTools import extractData
import database.CRUD.GET.Collectible.get_Collectible_CRUD_functions as crudFunctions

def getCollectibleByCollectibleId(event):
    """
    Retrieves a collectible by its collectibleId.
    Requires 'collectibleId' in the request data.
    """
    data = extractData(event)
    if not data or "collectibleId" not in data:
        return {'statusCode': 400, 'body': 'collectibleId is required'}

    collectible_id = data["collectibleId"]
    return crudFunctions.getCollectibleByCollectibleId(collectibleId=collectible_id, db=event['db_session'])

def getCollectibleByName(event):
    """
    Retrieves collectibles by their name.
    Requires 'name' in the request data. Optional 'skip' and 'limit' for pagination.
    """
    data = extractData(event)
    skip = 0
    limit = 100

    if not data or "name" not in data:
        return {'statusCode': 400, 'body': 'name is required'}

    name = data["name"]

    if "skip" in data:
        skip = data["skip"]
    if "limit" in data:
        limit = data["limit"]

    return crudFunctions.getCollectibleByName(name=name, skip=skip, limit=limit, db=event['db_session'])

def getCollectiblesByLabel(event):
    """
    Retrieves collectibles by their label.
    Requires 'label' in the request data. Optional 'skip' and 'limit' for pagination.
    """
    data = extractData(event)
    skip = 0
    limit = 100

    if not data or "label" not in data:
        return {'statusCode': 400, 'body': 'label is required'}

    label = data["label"]

    if "skip" in data:
        skip = data["skip"]
    if "limit" in data:
        limit = data["limit"]

    return crudFunctions.getCollectiblesByLabel(label=label, skip=skip, limit=limit, db=event['db_session'])

def getCollectiblesBySponsor(event):
    """
    Retrieves collectibles by sponsor ID.
    Requires 'sponsorId' in the request data. Optional 'skip' and 'limit' for pagination.
    """
    data = extractData(event)
    skip = 0
    limit = 100

    if not data or "sponsorId" not in data:
        return {'statusCode': 400, 'body': 'sponsorId is required'}

    sponsor_id = data["sponsorId"]

    if "skip" in data:
        skip = data["skip"]
    if "limit" in data:
        limit = data["limit"]

    return crudFunctions.getCollectiblesBySponsor(sponsorId=sponsor_id, skip=skip, limit=limit, db=event['db_session'])

def getCollectiblesByCollection(event):
    """
    Retrieves collectibles by collection ID.
    Requires 'collectionId' in the request data. Optional 'skip' and 'limit' for pagination.
    """
    data = extractData(event)
    skip = 0
    limit = 100

    if not data or "collectionId" not in data:
        return {'statusCode': 400, 'body': 'collectionId is required'}

    collection_id = data["collectionId"]

    if "skip" in data:
        skip = data["skip"]
    if "limit" in data:
        limit = data["limit"]

    return crudFunctions.getCollectiblesByCollection(collectionId=collection_id, skip=skip, limit=limit, db=event['db_session'])

def getCollectiblesByCommunity(event):
    """
    Retrieves collectibles by community ID.
    Requires 'communityId' in the request data. Optional 'skip' and 'limit' for pagination.
    """
    data = extractData(event)
    skip = 0
    limit = 100

    if not data or "communityId" not in data:
        return {'statusCode': 400, 'body': 'communityId is required'}

    community_id = data["communityId"]

    if "skip" in data:
        skip = data["skip"]
    if "limit" in data:
        limit = data["limit"]

    return crudFunctions.getCollectiblesByCommunity(communityId=community_id, skip=skip, limit=limit, db=event['db_session'])

def getAllCollectibles(event):
    """
    Retrieves all collectibles.
    Optional 'skip' and 'limit' for pagination.
    """
    data = extractData(event)
    skip = 0
    limit = 100

    if data is not None:  # Check if data is not None before trying to access it
        if "skip" in data:
            try:
                # Attempt to convert to int, handle potential errors
                skip_param = data.get("skip")
                if skip_param is not None: # Ensure skip_param is not None before int conversion
                    skip = int(skip_param)
            except (ValueError, TypeError):
                print(f"Warning: Invalid 'skip' parameter value: {data.get('skip')}. Using default {skip}.")
        if "limit" in data:
            try:
                # Attempt to convert to int, handle potential errors
                limit_param = data.get("limit")
                if limit_param is not None: # Ensure limit_param is not None before int conversion
                    limit = int(limit_param)
            except (ValueError, TypeError):
                print(f"Warning: Invalid 'limit' parameter value: {data.get('limit')}. Using default {limit}.")
    else:
        # This else block is optional, but can be useful for logging if you expect data
        print("Debug: No query parameters ('skip', 'limit') found for getAllCollectibles. Using defaults.")

    # Ensure event['db_session'] is available, as seen in your lambda_handler
    db_session = event.get('db_session')
    if db_session is None:
        # Handle missing db_session appropriately, e.g., raise an error or return an error response
        # This depends on how db_session is consistently injected into the event
        print("Error: db_session not found in event for getAllCollectibles.")
        # For now, let's assume it should always be there as per your lambda_handler structure
        # raise Exception("Database session is missing") 
        # Or return an error: return {"statusCode": 500, "body": "Internal server error: DB session missing"}
        # For now, will proceed assuming it's there, but this is a critical check.

    return crudFunctions.getAllCollectibles(skip=skip, limit=limit, db=db_session)

def getCollectiblesByProjectId(event):
    """
    Retrieves collectibles by project ID.
    Requires 'projectId' in the request data. Optional 'skip' and 'limit' for pagination.
    """
    data = extractData(event)
    skip = 0
    limit = 100

    if not data or "projectId" not in data:
        return {'statusCode': 400, 'body': 'projectId is required'}

    project_id = data["projectId"]

    if "skip" in data:
        skip = data["skip"]
    if "limit" in data:
        limit = data["limit"]

    return crudFunctions.getCollectiblesByProjectId(projectId=project_id, skip=skip, limit=limit, db=event['db_session'])

def getCollectiblesByCategoryId(event):
    """
    Retrieves collectibles by category ID.
    Requires 'categoryId' in the request data. Optional 'skip' and 'limit' for pagination.
    """
    data = extractData(event)
    skip = 0
    limit = 100

    if not data or "categoryId" not in data:
        return {'statusCode': 400, 'body': 'categoryId is required'}

    category_id = data["categoryId"]

    if "skip" in data:
        skip = data["skip"]
    if "limit" in data:
        limit = data["limit"]

    return crudFunctions.getCollectiblesByCategoryId(categoryId=category_id, skip=skip, limit=limit, db=event['db_session'])
