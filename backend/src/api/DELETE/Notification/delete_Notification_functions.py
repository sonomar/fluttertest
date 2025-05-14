from tools.prod.prodTools import extractData
import database.CRUD.DELETE.Notification.delete_Notification_CRUD_functions as crudFunctions



def deleteNotificationByNotificationId(event):
    """
    Deletes a Notification record by notificationId.
    Requires 'notificationId'.
    """
    data = extractData(event)
    if not data or "notificationId" not in data:
        return {'statusCode': 400, 'body': 'notificationId is required'}

    notification_id = data["notificationId"]
    return crudFunctions.deleteNotificationByNotificationId(notificationId=notification_id,db=event['db_session'])