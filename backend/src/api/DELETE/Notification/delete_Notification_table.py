import api.DELETE.Notification.delete_Notification_functions as notificationFunctions
from api.DELETE.api_paths_delete import API_PATHS_DELETE

def call_Notification_function(raw_path, event):
    
    returnString = 'Invalid Function Call'
    Notification_Path = API_PATHS_DELETE['Notification']

    ## Notification
    if raw_path == Notification_Path['deleteNotificationByNotificationId']['path']:
        returnString = notificationFunctions.deleteNotificationByNotificationId(event)

    return returnString