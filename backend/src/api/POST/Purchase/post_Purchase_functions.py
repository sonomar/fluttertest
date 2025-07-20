from tools.prod.prodTools import extractData
from database.schema.POST.Purchase.purchase_schema import PurchaseCreate
import database.CRUD.POST.Purchase.post_Purchase_CRUD_functions as crudFunctions
from pydantic import ValidationError

def createPurchase(event):
    data = extractData(event)
    if not data:
        return {'statusCode': 400, 'body': 'Request body is missing'}

    try:
        purchase_data = PurchaseCreate(**data)
    except ValidationError as e:
        return {'statusCode': 400, 'body': e.errors()}

    return crudFunctions.createPurchase(
        purchase=purchase_data,
        db=event["db_session"]
    )