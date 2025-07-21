from tools.prod.prodTools import extractData
import database.CRUD.GET.Purchase.get_Purchase_CRUD_functions as crudFunctions

def getPurchaseByPurchaseId(event):
    data = extractData(event)
    if not data or "purchaseId" not in data:
        return {'statusCode': 400, 'body': 'purchaseId is required'}

    purchase_id = data["purchaseId"]
    return crudFunctions.getPurchaseByPurchaseId(purchaseId=purchase_id, db=event['db_session'])

def getPurchasesByUserId(event):
    data = extractData(event)
    if not data or "userId" not in data:
        return {'statusCode': 400, 'body': 'userId is required'}

    user_id = data["userId"]
    skip = data.get("skip", 0)
    limit = data.get("limit", 100)
    return crudFunctions.getPurchasesByUserId(userId=user_id, skip=skip, limit=limit, db=event['db_session'])