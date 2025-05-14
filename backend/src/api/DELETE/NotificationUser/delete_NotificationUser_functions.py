from tools.prod.prodTools import extractData
import database.CRUD.DELETE.NotificationUser.delete_NotificationUser_CRUD_functions as crudFunctions



def deleteNotificationUserByNotificationUserId(event):
    """
    Deletes a NotificationUser record by notificationUserId.
    Requires 'notificationUserId'.
    """
    data = extractData(event)
    if not data or "notificationUserId" not in data:
        return {'statusCode': 400, 'body': 'notificationUserId is required'}

    notificationUser_id = data["notificationUserId"]
    return crudFunctions.deleteNotificationUserByNotificationUserId(notificationUserId=notificationUser_id,db=event['db_session'])