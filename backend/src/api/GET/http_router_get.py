# src/api/http_router_get.py
from tools.prod.prodTools import split_string

import api.table as table

# Import the call functions for each table's GET operations
import api.GET.User.get_User_table as Userfunctions
import api.GET.Collectible.get_Collectible_table as Collectiblefunctions
import api.GET.Project.get_Project_table as Projectfunctions
import api.GET.UserCollectible.get_UserCollectible_table as UserCollectiblefunctions
# Assuming similar modules exist for other tables in the older routing pattern
import api.GET.Category.get_Category_table as Categoryfunctions
import api.GET.Collection.get_Collection_table as Collectionfunctions
import api.GET.Community.get_Community_table as Communityfunctions
import api.GET.CommunityChallenge.get_CommunityChallenge_table as CommunityChallengefunctions
import api.GET.CommunityUser.get_CommunityUser_table as CommunityUserfunctions
import api.GET.Mission.get_Mission_table as Missionfunctions
import api.GET.MissionUser.get_MissionUser_table as MissionUserfunctions
import api.GET.MissionUserData.get_MissionUserData_table as MissionUserDatafunctions
import api.GET.NewsPost.get_NewsPost_table as NewsPostfunctions
import api.GET.Notification.get_Notification_table as Notificationfunctions
import api.GET.NotificationUser.get_NotificationUser_table as NotificationUserfunctions
import api.GET.Sponsor.get_Sponsor_table as Sponsorfunctions
import api.GET.CollectibleSponsor.get_CollectibleSponsor_table as CollectibleSponsorfunctions


def http_router_get(event):
    """
    Routes incoming GET requests based on the table name extracted from the path.

    This function is part of an older routing pattern and is likely being
    replaced by FastAPI's built-in routing in the new architecture.
    It assumes the existence of 'call_*_function' within table-specific modules.

    Args:
        event (dict): The incoming event object, expected to contain 'rawPath'.

    Returns:
        str or dict: The response from the called function or an error message.
    """
    # Split the raw path to get the table name and the specific function path
    # Assuming split_string correctly parses paths like "/table/function"
    tableName, raw_path = split_string(f"{event['rawPath']}")
    returnString = 'Invalid Function Path Call'

    # Route based on the extracted table name
    if tableName == table.User_table:
        # Call the specific function handler for the User table
        returnString = Userfunctions.call_User_function(raw_path, event)

    elif tableName == table.Collectible_table:
        # Call the specific function handler for the Collectible table
        returnString = Collectiblefunctions.call_Collectible_function(raw_path, event)

    elif tableName == table.Project_table:
        # Call the specific function handler for the Project table
        returnString = Projectfunctions.call_Project_function(raw_path, event)

    elif tableName == table.UserCollectible_table:
        # Call the specific function handler for the UserCollectible table
        returnString = UserCollectiblefunctions.call_UserCollectible_function(raw_path, event)

    # Add routing for the remaining tables following the same pattern
    elif tableName == table.Category_table:
        returnString = Categoryfunctions.call_Category_function(raw_path, event)

    elif tableName == table.Collection_table:
        returnString = Collectionfunctions.call_Collection_function(raw_path, event)

    elif tableName == table.Community_table:
        returnString = Communityfunctions.call_Community_function(raw_path, event)

    elif tableName == table.CommunityChallenge_table:
        returnString = CommunityChallengefunctions.call_CommunityChallenge_function(raw_path, event)

    elif tableName == table.CommunityUser_table:
        returnString = CommunityUserfunctions.call_CommunityUser_function(raw_path, event)

    elif tableName == table.Mission_table:
        returnString = Missionfunctions.call_Mission_function(raw_path, event)

    elif tableName == table.MissionUser_table:
        returnString = MissionUserfunctions.call_MissionUser_function(raw_path, event)

    elif tableName == table.MissionUserData_table:
        returnString = MissionUserDatafunctions.call_MissionUserData_function(raw_path, event)

    elif tableName == table.NewsPost_table:
        returnString = NewsPostfunctions.call_NewsPost_function(raw_path, event)

    elif tableName == table.Notification_table:
        returnString = Notificationfunctions.call_Notification_function(raw_path, event)

    elif tableName == table.NotificationUser_table:
        returnString = NotificationUserfunctions.call_NotificationUser_function(raw_path, event)

    elif tableName == table.Sponsor_table:
        returnString = Sponsorfunctions.call_Sponsor_function(raw_path, event)

    elif tableName == table.CollectibleSponsor_table:
        returnString = CollectibleSponsorfunctions.call_CollectibleSponsor_function(raw_path, event)

    # If the table name does not match any known tables, the initial
    # 'Invalid Function Path Call' message will be returned.

    return returnString
