import api.POST.PurchaseItem.post_PurchaseItem_functions as purchase_item
from api.POST.api_paths_post import API_PATHS_POST

def call_PurchaseItem_function(raw_path, event):

    returnString = 'Invalid Function Call'
    PurchaseItem_Path = API_PATHS_POST['PurchaseItem']

    if raw_path == PurchaseItem_Path['createPurchaseItem']['path']:
        returnString = purchase_item.createPurchaseItem(event)

    return returnString