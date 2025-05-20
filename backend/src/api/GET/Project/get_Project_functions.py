# database/CRUD/GET/Project/get_Project_table.py
from tools.prod.prodTools import extractData
import database.CRUD.GET.Project.get_Project_CRUD_functions as crudFunctions

def getProjectByProjectId(event):
    """
    Retrieves a project by its projectId.
    Requires 'projectId' in the request data.
    """
    data = extractData(event)
    if not data or "projectId" not in data:
        return {'statusCode': 400, 'body': 'projectId is required'}

    project_id = data["projectId"]
    return crudFunctions.getProjectByProjectId(projectId=project_id, db=event['db_session'])

def getProjectByName(event):
    """
    Retrieves projects by their name.
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

    return crudFunctions.getProjectByName(name=name, skip=skip, limit=limit, db=event['db_session'])