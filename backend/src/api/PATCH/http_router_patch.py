from tools.prod.prodTools import split_string
import api.table as table

import api.PATCH.User.patch_User_table as User_table_functions
import api.PATCH.Category.patch_Category_table as Category_table_functions
import api.PATCH.Community.patch_Community_table as Community_table_functions
import api.PATCH.Collection.patch_Collection_table as Collection_table_functions
import api.PATCH.Project.patch_Project_table as Project_table_functions
import api.PATCH.Collectible.patch_Collectible_table as Collectible_table_functions
import api.PATCH.UserCollectible.patch_UserCollectible_table as UserCollectible_table_functions
import api.PATCH.CommunityUser.patch_CommunityUser_table as CommunityUser_table_functions
import api.PATCH.Sponsor.patch_Sponsor_table as Sponsor_table_functions
import api.PATCH.CollectibleSponsor.patch_CollectibleSponsor_table as CollectibleSponsor_table_functions
import api.PATCH.Notification.patch_Notification_table as Notification_table_functions
import api.PATCH.NotificationUser.patch_NotificationUser_table as NotificationUser_table_functions
import api.PATCH.NewsPost.patch_NewsPost_table as NewsPost_table_functions
import api.PATCH.Mission.patch_Mission_table as Mission_table_functions
import api.PATCH.MissionUserData.patch_MissionUserData_table as MissionUserData_table_functions
import api.PATCH.MissionUser.patch_MissionUser_table as MissionUser_table_functions
import api.PATCH.CommunityChallenge.patch_CommunityChallenge_table as CommunityChallenge_table_functions


def http_router_patch(event):
    
    tableName, raw_path = split_string(f"{event['rawPath']}")
    returnString = 'Invalid Function Path Call'

    ## User
    if tableName == table.User_table:
        returnString = User_table_functions.call_User_function(raw_path, event)

    ## Category
    if tableName == table.Category_table:
        returnString = Category_table_functions.call_Category_function(raw_path, event)

    ## Community
    if tableName == table.Community_table:
        returnString = Community_table_functions.call_Community_function(raw_path, event)
    
    ## Collection
    if tableName == table.Collection_table:
        returnString = Collection_table_functions.call_Collection_function(raw_path, event)

    ## Project
    if tableName == table.Project_table:
        returnString = Project_table_functions.call_Project_function(raw_path, event)

    ## Collectible
    if tableName == table.Collectible_table:
        returnString = Collectible_table_functions.call_Collectible_function(raw_path, event)
    
    ## UserCollectible
    if tableName == table.UserCollectible_table:
        returnString = UserCollectible_table_functions.call_UserCollectible_function(raw_path, event)

    ## CommunityUser
    if tableName == table.CommunityUser_table:
        returnString = CommunityUser_table_functions.call_CommunityUser_function(raw_path, event)

    ## Sponsor
    if tableName == table.Sponsor_table:
        returnString = Sponsor_table_functions.call_Sponsor_function(raw_path, event)

    ## CollectibleSponsor
    if tableName == table.CollectibleSponsor_table:
        returnString = CollectibleSponsor_table_functions.call_CollectibleSponsor_function(raw_path, event)

    ## Notification
    if tableName == table.Notification_table:
        returnString = Notification_table_functions.call_Notification_function(raw_path, event)

    ## NotificationUser
    if tableName == table.NotificationUser_table:
        returnString = NotificationUser_table_functions.call_NotificationUser_function(raw_path, event)

    ## NewsPost
    if tableName == table.NewsPost_table:
        returnString = NewsPost_table_functions.call_NewsPost_function(raw_path, event)

    ## Mission
    if tableName == table.Mission_table:
        returnString = Mission_table_functions.call_Mission_function(raw_path, event)

    ## MissionUser
    if tableName == table.MissionUser_table:
        returnString = MissionUser_table_functions.call_MissionUser_function(raw_path, event)
            
    ## MissionUserData
    if tableName == table.MissionUserData_table:
        returnString = MissionUserData_table_functions.call_MissionUserData_function(raw_path, event)

    ## CommunityChallenge
    if tableName == table.CommunityChallenge_table:
        returnString = CommunityChallenge_table_functions.call_CommunityChallenge_function(raw_path, event)

    return returnString