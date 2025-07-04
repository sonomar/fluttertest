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

def getDistributionCodesByDistributionId(event):
    data = extractData(event)
    if not data or "distributionId" not in data:
        return {'statusCode': 400, 'body': 'distributionId is required'}
        
    distribution_id = data["distributionId"]
    return crudFunctions.getDistributionCodesByDistributionId(distributionId=distribution_id, db=event['db_session'])

def getDistributionCodeByCode(event):
    data = extractData(event)
    if not data or "code" not in data:
        return {'statusCode': 400, 'body': 'code is required'}
        
    code = data["code"]
    return crudFunctions.getDistributionCodeByCode(code=code, db=event['db_session'])