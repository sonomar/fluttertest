from tools.prod.prodTools import extractData
from database.schema.POST.PurchaseItem.purchaseItem_schema import PurchaseItemCreate
import database.CRUD.POST.PurchaseItem.post_PurchaseItem_CRUD_functions as crudFunctions
from pydantic import ValidationError

def createPurchaseItem(event):
    data = extractData(event)
    if not data:
        return {'statusCode': 400, 'body': 'Request body is missing'}

    try:
        purchase_item_data = PurchaseItemCreate(**data)
    except ValidationError as e:
        return {'statusCode': 400, 'body': e.errors()}

    return crudFunctions.createPurchaseItem(
        purchase_item=purchase_item_data,
        db=event["db_session"]
    )