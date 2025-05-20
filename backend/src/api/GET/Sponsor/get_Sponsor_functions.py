# database/CRUD/GET/Sponsor/get_Sponsor_table.py
from tools.prod.prodTools import extractData
import database.CRUD.GET.Sponsor.get_Sponsor_CRUD_functions as crudFunctions

def getSponsorById(event):
    """
    Retrieves a sponsor by its sponsorId.
    Requires 'sponsorId' in the request data.
    """
    data = extractData(event)
    if not data or "sponsorId" not in data:
        return {'statusCode': 400, 'body': 'sponsorId is required'}

    sponsor_id = data["sponsorId"]
    return crudFunctions.getSponsorById(sponsorId=sponsor_id, db=event['db_session'])

def getSponsorByName(event):
    """
    Retrieves sponsors by their name.
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

    return crudFunctions.getSponsorByName(name=name, skip=skip, limit=limit, db=event['db_session'])

def getSponsorByOrganization(event):
    """
    Retrieves sponsors by their organization.
    Requires 'organization' in the request data. Optional 'skip' and 'limit' for pagination.
    """
    data = extractData(event)
    skip = 0
    limit = 100

    if not data or "organization" not in data:
        return {'statusCode': 400, 'body': 'organization is required'}

    organization = data["organization"]

    if "skip" in data:
        skip = data["skip"]
    if "limit" in data:
        limit = data["limit"]

    return crudFunctions.getSponsorByOrganization(organization=organization, skip=skip, limit=limit, db=event['db_session'])