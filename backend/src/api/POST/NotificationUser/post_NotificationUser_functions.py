# database/CRUD/POST/NotificationUser/post_NotificationUser_table.py
from tools.prod.prodTools import extractData
from database.schema.POST.NotificationUser.notificationUser_schema import NotificationUserCreate
import database.CRUD.POST.NotificationUser.post_NotificationUser_CRUD_functions as crudFunctions

def create_notification_user(event):
    """
    Adds a new notification user entry to the database.
    Requires 'notificationId', 'userId'. Other fields are optional.
    """
    data = extractData(event)

    # Basic validation for required fields
    if not data or "notificationId" not in data or "userId" not in data:
        return {
            "statusCode": 400,
            "body": "notificationId and userId are required"
        }

    # Create Pydantic model instance
    notification_user = NotificationUserCreate(
        notificationId=data["notificationId"],
        userId=data["userId"],
        markRead=data.get("markRead"), # Schema default is False if not provided
        archived=data.get("archived"), # Schema default is False if not provided
        deleted=data.get("deleted"), # Schema default is False if not provided
        pushNotification=data.get("pushNotification") # Schema default is False if not provided
    )

    # Call the CRUD function with the Pydantic model and DB session
    # Assumes event["db_session"] contains the SQLAlchemy session
    return crudFunctions.create_notification_user(notification_user=notification_user, db=event["db_session"])