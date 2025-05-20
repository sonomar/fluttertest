# database/CRUD/POST/NewsPost/post_NewsPost_table.py
from tools.prod.prodTools import extractData
from database.schema.POST.NewsPost.newsPost_schema import NewsPostCreate
import database.CRUD.POST.NewsPost.post_NewsPost_CRUD_functions as crudFunctions

def create_news_post(event):
    """
    Adds a new news post to the database.
    Requires 'header', 'body', 'shortBody'. Other fields are optional.
    """
    data = extractData(event)

    # Basic validation for required fields
    if not data or "header" not in data or "body" not in data or "shortBody" not in data:
        return {
            "statusCode": 400,
            "body": "header, body, and shortBody are required"
        }

    # Create Pydantic model instance
    news_post = NewsPostCreate(
        header=data["header"],
        body=data["body"],
        shortBody=data["shortBody"],
        postDate=data.get("postDate"), # Schema default is utcnow if not provided
        type=data.get("type"),
        imgRef=data.get("imgRef"),
        vidRef=data.get("vidRef"),
        qrRef=data.get("qrRef"),
        embedRef=data.get("embedRef"),
        active=data.get("active") # Schema default is True if not provided
    )

    # Call the CRUD function with the Pydantic model and DB session
    # Assumes event["db_session"] contains the SQLAlchemy session
    return crudFunctions.create_news_post(news_post=news_post, db=event["db_session"])