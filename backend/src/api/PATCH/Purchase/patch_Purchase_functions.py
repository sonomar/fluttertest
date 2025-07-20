from tools.prod.prodTools import extractData
import database.CRUD.PATCH.Purchase.patch_Purchase_CRUD_functions as crudFunctions
from database.schema.PATCH.Purchase.purchase_schema import PurchaseUpdate
from pydantic import ValidationError

def updatePurchaseByPurchaseId(event):
    data = extractData(event)
    if not data or "purchaseId" not in data:
        return {'statusCode': 400, 'body': 'purchaseId is required'}

    purchase_id = data.pop("purchaseId")

    try:
        purchase_update_data = PurchaseUpdate(**data)
    except ValidationError as e:
        return {'statusCode': 400, 'body': e.errors()}

    return crudFunctions.updatePurchaseByPurchaseId(
        purchaseId=purchase_id,
        purchase_update_data=purchase_update_data,
        db=event['db_session']
    )