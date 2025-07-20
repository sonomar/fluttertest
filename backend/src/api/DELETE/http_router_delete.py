from tools.prod.prodTools import split_string
import api.table as table
import api.DELETE.User.delete_User_table as User_table_functions
import api.DELETE.Category.delete_Category_table as Category_table_functions
import api.DELETE.Community.delete_Community_table as Community_table_functions
import api.DELETE.Collection.delete_Collection_table as Collection_table_functions
import api.DELETE.Project.delete_Project_table as Project_table_functions
import api.DELETE.Collectible.delete_Collectible_table as Collectible_table_functions
import api.DELETE.UserCollectible.delete_UserCollectible_table as UserCollectible_table_functions
import api.DELETE.CommunityUser.delete_CommunityUser_table as CommunityUser_table_functions
import api.DELETE.Sponsor.delete_Sponsor_table as Sponsor_table_functions
import api.DELETE.CollectibleSponsor.delete_CollectibleSponsor_table as CollectibleSponsor_table_functions
import api.DELETE.Notification.delete_Notification_table as Notification_table_functions
import api.DELETE.NotificationUser.delete_NotificationUser_table as NotificationUser_table_functions
import api.DELETE.NewsPost.delete_NewsPost_table as NewsPost_table_functions
import api.DELETE.Mission.delete_Mission_table as Mission_table_functions
import api.DELETE.MissionUserData.delete_MissionUserData_table as MissionUserData_table_functions
import api.DELETE.MissionUser.delete_MissionUser_table as MissionUser_table_functions
import api.DELETE.CommunityChallenge.delete_CommunityChallenge_table as CommunityChallenge_table_functions
import api.DELETE.Distribution.delete_Distribution_table as Distributionfunctions
import api.DELETE.DistributionCode.delete_DistributionCode_table as DistributionCodefunctions
import api.DELETE.DistributionCodeUser.delete_DistributionCodeUser_table as DistributionCodeUserfunctions
import api.DELETE.DistributionCollectible.delete_DistributionCollectible_table as DistributionCollectiblefunctions
import api.DELETE.MissionType.delete_MissionType_table as MissionType_table_functions
import api.DELETE.Purchase.delete_Purchase_table as Purchase_table_functions
import api.DELETE.PurchaseItem.delete_PurchaseItem_table as PurchaseItem_table_functions


def http_router_delete(event):
    
    tableName, raw_path = split_string(f"{event['rawPath']}")
    returnString = 'Invalid Function Path Call'
    
    ## User
    if tableName == table.User_table:
        returnString = User_table_functions.call_User_function(raw_path, event)
    
    ## Category
    elif tableName == table.Category_table:
        returnString = Category_table_functions.call_Category_function(raw_path, event)

    ## Community
    elif tableName == table.Community_table:
        returnString = Community_table_functions.call_Community_function(raw_path, event)
    
    ## Collection
    elif tableName == table.Collection_table:
        returnString = Collection_table_functions.call_Collection_function(raw_path, event)

    ## Project
    elif tableName == table.Project_table:
        returnString = Project_table_functions.call_Project_function(raw_path, event)

    ## Collectible
    elif tableName == table.Collectible_table:
        returnString = Collectible_table_functions.call_Collectible_function(raw_path, event)
    
    ## UserCollectible
    elif tableName == table.UserCollectible_table:
        returnString = UserCollectible_table_functions.call_UserCollectible_function(raw_path, event)

    ## CommunityUser
    elif tableName == table.CommunityUser_table:
        returnString = CommunityUser_table_functions.call_CommunityUser_function(raw_path, event)

    ## Sponsor
    elif tableName == table.Sponsor_table:
        returnString = Sponsor_table_functions.call_Sponsor_function(raw_path, event)

    ## CollectibleSponsor
    elif tableName == table.CollectibleSponsor_table:
        returnString = CollectibleSponsor_table_functions.call_CollectibleSponsor_function(raw_path, event)

    ## Notification
    elif tableName == table.Notification_table:
        returnString = Notification_table_functions.call_Notification_function(raw_path, event)

    ## NotificationUser
    elif tableName == table.NotificationUser_table:
        returnString = NotificationUser_table_functions.call_NotificationUser_function(raw_path, event)

    ## NewsPost
    elif tableName == table.NewsPost_table:
        returnString = NewsPost_table_functions.call_NewsPost_function(raw_path, event)

    ## Mission
    elif tableName == table.Mission_table:
        returnString = Mission_table_functions.call_Mission_function(raw_path, event)

    ## MissionType
    elif tableName == table.MissionType_table:
        returnString = MissionType_table_functions.call_MissionType_function(raw_path, event)

    ## MissionUser
    elif tableName == table.MissionUser_table:
        returnString = MissionUser_table_functions.call_MissionUser_function(raw_path, event)
            
    ## MissionUserData
    elif tableName == table.MissionUserData_table:
        returnString = MissionUserData_table_functions.call_MissionUserData_function(raw_path, event)

    ## CommunityChallenge
    elif tableName == table.CommunityChallenge_table:
        returnString = CommunityChallenge_table_functions.call_CommunityChallenge_function(raw_path, event)

    elif tableName == table.Distribution_table:
        returnString = Distributionfunctions.call_Distribution_function(raw_path, event)

    elif tableName == table.DistributionCode_table:
        returnString = DistributionCodefunctions.call_DistributionCode_function(raw_path, event)

    elif tableName == table.DistributionCodeUser_table:
        returnString = DistributionCodeUserfunctions.call_DistributionCodeUser_function(raw_path, event)
    
    elif tableName == table.DistributionCollectible_table:
        returnString = DistributionCollectiblefunctions.call_DistributionCollectible_function(raw_path, event)

    elif tableName == table.Purchase_table:
        returnString = Purchase_table_functions.call_Purchase_function(raw_path, event)
        
    elif tableName == table.PurchaseItem_table:
        returnString = PurchaseItem_table_functions.call_PurchaseItem_function(raw_path, event)

    return returnString