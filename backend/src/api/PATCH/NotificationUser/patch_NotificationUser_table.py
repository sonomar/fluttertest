import api.PATCH.NotificationUser.patch_NotificationUser_functions as notificationUser
from api.PATCH.api_paths_patch import API_PATHS_PATCH

def call_NotificationUser_function(raw_path, event):
    
    returnString = 'Invalid Function Call'
    NotificationUser_Path = API_PATHS_PATCH['NotificationUser']

    ## NotificationUser
    if raw_path == NotificationUser_Path['updateNotificationUserByNotificationUserId']['path']:
        returnString = notificationUser.updateNotificationUserByNotificationUserId(event)

    return returnString