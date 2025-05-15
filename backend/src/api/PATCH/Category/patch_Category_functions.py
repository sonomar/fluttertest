from tools.prod.prodTools import extractData
import database.CRUD.PATCH.Category.patch_Category_CRUD_functions as crudFunctions
from database.schema.PATCH.Category.category_schema import CategoryUpdate

def CategoryDataCheck(category: CategoryUpdate, data: any):
    if "name" in data:
        category.name = data["name"]
    return category

def updateCategoryByCategoryId(event):
    data = extractData(event)
    if not data or "categoryId" not in data:
        return {'statusCode': 400, 'body': 'categoryId is required'}

    category_id = data["categoryId"]
    category = CategoryUpdate()
    category = CategoryDataCheck(category, data)
    return crudFunctions.updateCategoryByCategoryId(categoryId=category_id, category_update_data=category, db=event['db_session'])