from tools.prod.prodTools import extractData
import database.CRUD.GET.Distribution.get_Distribution_CRUD_functions as crudFunctions

def getDistributionByDistributionId(event):
    data = extractData(event)
    if not data or "distributionId" not in data:
        return {'statusCode': 400, 'body': 'distributionId is required'}
    
    distribution_id = data["distributionId"]
    return crudFunctions.getDistributionByDistributionId(distributionId=distribution_id, db=event['db_session'])

def getAllDistributions(event):
    data = extractData(event)
    skip = 0
    limit = 100
    if data:
        skip = data.get("skip", 0)
        limit = data.get("limit", 100)
        
    return crudFunctions.getAllDistributions(skip=skip, limit=limit, db=event['db_session'])

def getDistributionsByProjectId(event):
    data = extractData(event)
    if not data or "projectId" not in data:
        return {'statusCode': 400, 'body': 'projectId is required'}
        
    project_id = data["projectId"]
    return crudFunctions.getDistributionsByProjectId(projectId=project_id, db=event['db_session'])