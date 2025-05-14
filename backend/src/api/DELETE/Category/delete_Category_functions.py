from tools.prod.prodTools import extractData
import database.CRUD.DELETE.Category.delete_Category_CRUD_functions as crudFunctions


def deleteCategoryByCategoryId(event):
    """
    Deletes a Category record by categoryId.
    Requires 'categoryId'.
    """
    data = extractData(event)
    if not data or "categoryId" not in data:
        return {'statusCode': 400, 'body': 'categoryId is required'}

    category_id = data["categoryId"]
    return crudFunctions.deleteCategoryByCategoryId(categoryId=category_id,db=event['db_session'])