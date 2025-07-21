from tools.prod.prodTools import extractData
import database.CRUD.GET.PurchaseItem.get_PurchaseItem_CRUD_functions as crudFunctions

def getPurchaseItemsByPurchaseId(event):
    data = extractData(event)
    if not data or "purchaseId" not in data:
        return {'statusCode': 400, 'body': 'purchaseId is required'}

    purchase_id = data["purchaseId"]
    skip = data.get("skip", 0)
    limit = data.get("limit", 100)
    return crudFunctions.getPurchaseItemsByPurchaseId(purchaseId=purchase_id, skip=skip, limit=limit, db=event['db_session'])