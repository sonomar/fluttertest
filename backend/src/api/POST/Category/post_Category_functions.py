# database/CRUD/POST/Category/post_Category_table.py
from tools.prod.prodTools import extractData
from database.schema.POST.Category.category_schema import CategoryCreate
import database.CRUD.POST.Category.post_Category_CRUD_functions as crudFunctions

def create_category(event):
    """
    Adds a new category to the database.
    Requires 'name'.
    """
    data = extractData(event)

    # Basic validation for required fields
    if not data or "name" not in data:
        return {
            "statusCode": 400,
            "body": "name is required"
        }

    # Create Pydantic model instance
    category = CategoryCreate(name=data["name"])

    # Call the CRUD function with the Pydantic model and DB session
    # Assumes event["db_session"] contains the SQLAlchemy session
    return crudFunctions.create_category(category=category, db=event["db_session"])