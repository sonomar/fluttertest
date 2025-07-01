from tools.prod.prodTools import extractData
import database.CRUD.GET.DistributionCode.get_DistributionCode_CRUD_functions as crudFunctions

def getDistributionCodeByDistributionCodeId(event):
    data = extractData(event)
    if not data or "distributionCodeId" not in data:
        return {'statusCode': 400, 'body': 'distributionCodeId is required'}
    
    distribution_code_id = data["distributionCodeId"]
    return crudFunctions.getDistributionCodeByDistributionCodeId(distributionCodeId=distribution_code_id, db=event['db_session'])

def getAllDistributionCodes(event):
    data = extractData(event)
    skip = 0
    limit = 100
    if data:
        skip = data.get("skip", 0)
        limit = data.get("limit", 100)
        
    return crudFunctions.getAllDistributionCodes(skip=skip, limit=limit, db=event['db_session'])