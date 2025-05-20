# database/CRUD/GET/Category/get_Category_table.py
from tools.prod.prodTools import extractData
import database.CRUD.GET.Category.get_Category_CRUD_functions as crudFunctions

def getCategoryByCategoryId(event):
    """
    Retrieves a category by its categoryId.
    Requires 'categoryId' in the request data.
    """
    data = extractData(event)
    if not data or "categoryId" not in data:
        return {'statusCode': 400, 'body': 'categoryId is required'}

    category_id = data["categoryId"]
    return crudFunctions.getCategoryByCategoryId(categoryId=category_id, db=event['db_session'])