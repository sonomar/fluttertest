from tools.prod.prodTools import extractData
import database.CRUD.PATCH.DistributionCodeUser.patch_DistributionCodeUser_CRUD_functions as crudFunctions
from database.schema.PATCH.DistributionCodeUser.distributionCodeUser_schema import DistributionCodeUserUpdate

def updateDistributionCodeUserByDistributionCodeUserId(event):
    data = extractData(event)
    if not data or "distributionCodeUserId" not in data:
        return {'statusCode': 400, 'body': 'distributionCodeUserId is required'}
    
    distribution_code_user_id = data["distributionCodeUserId"]
    distribution_code_user = DistributionCodeUserUpdate(**data)
    
    return crudFunctions.updateDistributionCodeUserByDistributionCodeUserId(distributionCodeUserId=distribution_code_user_id, distribution_code_user=distribution_code_user, db=event['db_session'])