from tools.prod.prodTools import extractData
import database.CRUD.DELETE.DistributionCodeUser.delete_DistributionCodeUser_CRUD_functions as crudFunctions

def deleteDistributionCodeUserByDistributionCodeUserId(event):
    data = extractData(event)
    if not data or "distributionCodeUserId" not in data:
        return {'statusCode': 400, 'body': 'distributionCodeUserId is required'}
    
    distribution_code_user_id = data["distributionCodeUserId"]
    
    return crudFunctions.deleteDistributionCodeUserByDistributionCodeUserId(distributionCodeUserId=distribution_code_user_id, db=event['db_session'])