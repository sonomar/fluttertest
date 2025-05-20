# database/CRUD/GET/NotificationUser/get_NotificationUser_table.py
from tools.prod.prodTools import extractData
import database.CRUD.GET.NotificationUser.get_NotificationUser_CRUD_functions as crudFunctions

def getNotificationUsersByUserId(event):
    """
    Retrieves notification user records by user ID.
    Requires 'userId' in the request data. Optional 'skip' and 'limit' for pagination.
    """
    data = extractData(event)
    skip = 0
    limit = 100

    if not data or "userId" not in data:
        return {'statusCode': 400, 'body': 'userId is required'}

    user_id = data["userId"]

    if "skip" in data:
        skip = data["skip"]
    if "limit" in data:
        limit = data["limit"]

    return crudFunctions.getNotificationUsersByUserId(userId=user_id, skip=skip, limit=limit, db=event['db_session'])

def getNotificationUsersByNotificationId(event):
    """
    Retrieves notification user records by notification ID.
    Requires 'notificationId' in the request data. Optional 'skip' and 'limit' for pagination.
    """
    data = extractData(event)
    skip = 0
    limit = 100

    if not data or "notificationId" not in data:
        return {'statusCode': 400, 'body': 'notificationId is required'}

    notification_id = data["notificationId"]

    if "skip" in data:
        skip = data["skip"]
    if "limit" in data:
        limit = data["limit"]

    return crudFunctions.getNotificationUsersByNotificationId(notificationId=notification_id, skip=skip, limit=limit, db=event['db_session'])

def getNotificationUsersByUserIdAndDate(event):
    """
    Retrieves notification user records by user ID and creation date.
    Requires 'userId' and 'createdDtAfter' in the request data. Optional 'skip' and 'limit' for pagination.
    """
    data = extractData(event)
    skip = 0
    limit = 100

    if not data or "userId" not in data or "createdDtAfter" not in data:
        return {'statusCode': 400, 'body': 'userId and createdDtAfter are required'}

    user_id = data["userId"]
    created_dt_after = data["createdDtAfter"]

    if "skip" in data:
        skip = data["skip"]
    if "limit" in data:
        limit = data["limit"]

    return crudFunctions.getNotificationUsersByUserIdAndDate(userId=user_id, createdDtAfter=created_dt_after, skip=skip, limit=limit, db=event['db_session'])