from tools.prod.prodTools import extractData
import database.CRUD.GET.DistributionCodeUser.get_DistributionCodeUser_CRUD_functions as crudFunctions

def getDistributionCodeUserByDistributionCodeUserId(event):
    data = extractData(event)
    if not data or "distributionCodeUserId" not in data:
        return {'statusCode': 400, 'body': 'distributionCodeUserId is required'}
    
    distribution_code_user_id = data["distributionCodeUserId"]
    return crudFunctions.getDistributionCodeUserByDistributionCodeUserId(distributionCodeUserId=distribution_code_user_id, db=event['db_session'])

def getAllDistributionCodeUsers(event):
    data = extractData(event)
    skip = 0
    limit = 100
    if data:
        skip = data.get("skip", 0)
        limit = data.get("limit", 100)
        
    return crudFunctions.getAllDistributionCodeUsers(skip=skip, limit=limit, db=event['db_session'])