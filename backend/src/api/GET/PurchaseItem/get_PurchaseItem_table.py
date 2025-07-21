import api.GET.PurchaseItem.get_PurchaseItem_functions as purchase_item
from api.GET.api_paths_get import API_PATHS_GET

def call_PurchaseItem_function(raw_path, event):

    returnString = 'Invalid Function Call'
    PurchaseItem_Path = API_PATHS_GET['PurchaseItem']

    if raw_path == PurchaseItem_Path['getPurchaseItemsByPurchaseId']['path']:
        returnString = purchase_item.getPurchaseItemsByPurchaseId(event)

    return returnString