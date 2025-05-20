# database/CRUD/POST/Notification/post_Notification_table.py
from tools.prod.prodTools import extractData
from database.schema.POST.Notification.notification_schema import NotificationCreate
import database.CRUD.POST.Notification.post_Notification_CRUD_functions as crudFunctions

def create_notification(event):
    """
    Adds a new notification to the database.
    Requires 'header', 'content'. Other fields are optional.
    """
    data = extractData(event)

    # Basic validation for required fields
    if not data or "header" not in data or "content" not in data:
        return {
            "statusCode": 400,
            "body": "header and content are required"
        }

    # Create Pydantic model instance
    notification = NotificationCreate(
        header=data["header"],
        content=data["content"],
        link=data.get("link"),
        pushNotification=data.get("pushNotification"), # Schema default is False if not provided
        private=data.get("private"), # Schema default is False if not provided
        imgRef=data.get("imgRef"),
        vidRef=data.get("vidRef"),
        qrRef=data.get("qrRef"),
        embedRef=data.get("embedRef"),
        active=data.get("active") # Schema default is True if not provided
    )

    # Call the CRUD function with the Pydantic model and DB session
    # Assumes event["db_session"] contains the SQLAlchemy session
    return crudFunctions.create_notification(notification=notification, db=event["db_session"])