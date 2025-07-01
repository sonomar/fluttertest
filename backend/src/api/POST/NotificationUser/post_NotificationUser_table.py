import api.POST.NotificationUser.post_NotificationUser_functions as notificationUser
from api.POST.api_paths_post import API_PATHS_POST

def call_NotificationUser_function(raw_path, event):
    
    returnString = 'Invalid Function Call'
    NotificationUser_Path = API_PATHS_POST['NotificationUser']

    ## NotificationUser
    if raw_path == NotificationUser_Path['createNotificationUser']['path']:
        returnString = notificationUser.createNotificationUser(event)

    return returnString