from tools.prod.prodTools import split_string
import api.table as table
import api.DELETE.User.delete_User_table as Userfunctions

def http_router_delete(event):
    
    tableName, raw_path = split_string(f"{event['rawPath']}")
    returnString = 'Invalid Function Path Call'
    
    ## User
    if tableName == table.User_table:
        returnString = Userfunctions.call_User_function(raw_path, event)

    return returnString