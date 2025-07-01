from tools.prod.prodTools import extractData
import database.CRUD.DELETE.Distribution.delete_Distribution_CRUD_functions as crudFunctions

def deleteDistributionByDistributionId(event):
    data = extractData(event)
    if not data or "distributionId" not in data:
        return {'statusCode': 400, 'body': 'distributionId is required'}
    
    distribution_id = data["distributionId"]
    
    return crudFunctions.deleteDistributionByDistributionId(distributionId=distribution_id, db=event['db_session'])