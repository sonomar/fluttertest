from tools.prod.prodTools import extractData
import database.CRUD.PATCH.PurchaseItem.patch_PurchaseItem_CRUD_functions as crudFunctions
from database.schema.PATCH.PurchaseItem.purchaseItem_schema import PurchaseItemUpdate
from pydantic import ValidationError

def updatePurchaseItemByPurchaseItemId(event):
    data = extractData(event)
    if not data or "purchaseItemId" not in data:
        return {'statusCode': 400, 'body': 'purchaseItemId is required'}

    purchase_item_id = data.pop("purchaseItemId")

    try:
        purchase_item_update_data = PurchaseItemUpdate(**data)
    except ValidationError as e:
        return {'statusCode': 400, 'body': e.errors()}

    return crudFunctions.updatePurchaseItemByPurchaseItemId(
        purchaseItemId=purchase_item_id,
        purchase_item_update_data=purchase_item_update_data,
        db=event['db_session']
    )