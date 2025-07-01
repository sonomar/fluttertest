from tools.prod.prodTools import extractData
import database.CRUD.DELETE.DistributionCode.delete_DistributionCode_CRUD_functions as crudFunctions

def deleteDistributionCodeByDistributionCodeId(event):
    data = extractData(event)
    if not data or "distributionCodeId" not in data:
        return {'statusCode': 400, 'body': 'distributionCodeId is required'}
    
    distribution_code_id = data["distributionCodeId"]
    
    return crudFunctions.deleteDistributionCodeByDistributionCodeId(distributionCodeId=distribution_code_id, db=event['db_session'])