import api.GET.api_path_get as api_path_get
from tools.prod.prodTools import split_string
import api.GET.Collectible.get_Collectible_table as collectible
import api.GET.User.get_User_table as user
import api.GET.Project.get_Project_table as project
import api.GET.UserCollectibles.get_UserCollectibles_table as userCollectibles

def http_router_get(event):
    
    raw_path = split_string(f"{event['rawPath']}")
    returnString = 'Invalid Function Call'

    ## User
    if raw_path == api_path_get.GET_RAW_PATH_getUserByUserId:
        returnString = user.getUserByUserId(event)

    elif raw_path == api_path_get.GET_RAW_PATH_getUserByEmail:
        returnString = user.getUserByEmail(event)

    elif raw_path == api_path_get.GET_RAW_PATH_getUserByUsername:
        returnString = user.getUserByUsername(event)
    
    elif raw_path == api_path_get.GET_RAW_PATH_getUsersByLastLoggedIn:
        returnString = user.getUsersByLastLoggedIn(event)

    ## Collectible
    elif raw_path == api_path_get.GET_RAW_PATH_getAllCollectibles:
        returnString = collectible.getAllCollectibles(event)
    
    elif raw_path == api_path_get.GET_RAW_PATH_getCollectibleByCollectibleId:
        returnString = collectible.getCollectibleByCollectibleId(event)
    
    elif raw_path == api_path_get.GET_RAW_PATH_getCollectiblesByProjectId:
        returnString = collectible.getCollectiblesByProjectId(event)

    elif raw_path == api_path_get.GET_RAW_PATH_getCollectiblesByCategoryId:
        returnString = collectible.getCollectiblesByCategoryId(event)

    ## Project
    elif raw_path == api_path_get.GET_RAW_PATH_getProjectByProjectId:
        returnString = project.getProjectByProjectId(event)

    ## UserCollectibles
    elif raw_path == api_path_get.GET_RAW_PATH_getUserCollectiblesByUserId:
        returnString = userCollectibles.getUserCollectiblesByUserId(event)

    return returnString