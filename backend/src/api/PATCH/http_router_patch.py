from tools.prod.prodTools import split_string
import api.table as table
import api.PATCH.User.patch_User_table as Userfunctions


def http_router_patch(event):
    
    tableName, raw_path = split_string(f"{event['rawPath']}")
    returnString = 'Invalid Function Path Call'

    ## User
    if tableName == table.User_table:
        returnString = Userfunctions.call_User_function(raw_path, event)
        
    return returnString