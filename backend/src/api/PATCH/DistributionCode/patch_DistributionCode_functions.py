from tools.prod.prodTools import extractData
import database.CRUD.PATCH.DistributionCode.patch_DistributionCode_CRUD_functions as crudFunctions
from database.schema.PATCH.DistributionCode.distributionCode_schema import DistributionCodeUpdate

def updateDistributionCodeByDistributionCodeId(event):
    data = extractData(event)
    if not data or "distributionCodeId" not in data:
        return {'statusCode': 400, 'body': 'distributionCodeId is required'}
    
    distribution_code_id = data["distributionCodeId"]
    distribution_code = DistributionCodeUpdate(**data)
    
    return crudFunctions.updateDistributionCodeByDistributionCodeId(distributionCodeId=distribution_code_id, distribution_code=distribution_code, db=event['db_session'])