from tools.prod.prodTools import split_string

import api.table as table

import api.GET.User.get_User_table as Userfunctions
import api.GET.Collectible.get_Collectible_table as Collectiblefunctions
import api.GET.Project.get_Project_table as Projectfunctions
import api.GET.UserCollectible.get_UserCollectible_table as UserCollectiblefunctions


def http_router_get(event):
    
    tableName, raw_path = split_string(f"{event['rawPath']}")
    returnString = 'Invalid Function Path Call'

    ## User
    if tableName == table.User_table:
        returnString = Userfunctions.call_User_function(raw_path, event)

    ## Collectible
    elif tableName == table.Collectible_table:
        returnString = Collectiblefunctions.call_Collectible_function(raw_path, event)

    ## Project
    elif tableName == table.Project_table:
        returnString = Projectfunctions.call_Project_function(raw_path, event)

    ## UserCollectible
    elif tableName == table.UserCollectible_table:
        returnString = UserCollectiblefunctions.call_UserCollectible_function(raw_path, event)

    return returnString