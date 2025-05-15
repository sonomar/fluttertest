import api.PATCH.Notification.patch_Notification_functions as notification
from api.PATCH.api_paths_patch import API_PATHS_PATCH

def call_Notification_function(raw_path, event):
    
    returnString = 'Invalid Function Call'
    Notification_Path = API_PATHS_PATCH['Notification']

    ## Notification
    if raw_path == Notification_Path['updateNotificationByNotificationId']['path']:
        returnString = notification.updateNotificationByNotificationId(event)

    return returnString