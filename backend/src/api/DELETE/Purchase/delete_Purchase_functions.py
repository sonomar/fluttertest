from tools.prod.prodTools import extractData
import database.CRUD.DELETE.Purchase.delete_Purchase_CRUD_functions as crudFunctions

def deletePurchaseByPurchaseId(event):
    data = extractData(event)
    if not data or "purchaseId" not in data:
        return {'statusCode': 400, 'body': 'purchaseId is required'}

    purchase_id = data["purchaseId"]
    return crudFunctions.deletePurchaseByPurchaseId(purchaseId=purchase_id, db=event['db_session'])