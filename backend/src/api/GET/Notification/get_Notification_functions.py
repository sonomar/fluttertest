# database/CRUD/GET/Notification/get_Notification_table.py
from tools.prod.prodTools import extractData
import database.CRUD.GET.Notification.get_Notification_CRUD_functions as crudFunctions

def getNotificationById(event):
    """
    Retrieves a notification by its notificationId.
    Requires 'notificationId' in the request data.
    """
    data = extractData(event)
    if not data or "notificationId" not in data:
        return {'statusCode': 400, 'body': 'notificationId is required'}

    notification_id = data["notificationId"]
    return crudFunctions.getNotificationById(notificationId=notification_id, db=event['db_session'])

def getNotificationsByDate(event):
    """
    Retrieves notifications by creation date.
    Requires 'createdDtAfter' timestamp in the request data. Optional 'skip' and 'limit' for pagination.
    """
    data = extractData(event)
    skip = 0
    limit = 100

    if not data or "createdDtAfter" not in data:
        return {'statusCode': 400, 'body': 'createdDtAfter timestamp is required'}

    created_dt_after = data["createdDtAfter"]

    if "skip" in data:
        skip = data["skip"]
    if "limit" in data:
        limit = data["limit"]

    return crudFunctions.getNotificationsByDate(createdDtAfter=created_dt_after, skip=skip, limit=limit, db=event['db_session'])

def getNotificationsByHeader(event):
    """
    Retrieves notifications by their header.
    Requires 'header' in the request data. Optional 'skip' and 'limit' for pagination.
    """
    data = extractData(event)
    skip = 0
    limit = 100

    if not data or "header" not in data:
        return {'statusCode': 400, 'body': 'header is required'}

    header = data["header"]

    if "skip" in data:
        skip = data["skip"]
    if "limit" in data:
        limit = data["limit"]

    return crudFunctions.getNotificationsByHeader(header=header, skip=skip, limit=limit, db=event['db_session'])