from tools.prod.prodTools import extractData
import database.CRUD.DELETE.PurchaseItem.delete_PurchaseItem_CRUD_functions as crudFunctions

def deletePurchaseItemByPurchaseItemId(event):
    data = extractData(event)
    if not data or "purchaseItemId" not in data:
        return {'statusCode': 400, 'body': 'purchaseItemId is required'}

    purchase_item_id = data["purchaseItemId"]
    return crudFunctions.deletePurchaseItemByPurchaseItemId(purchaseItemId=purchase_item_id, db=event['db_session'])