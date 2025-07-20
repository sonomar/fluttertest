import api.DELETE.PurchaseItem.delete_PurchaseItem_functions as purchase_item
from api.DELETE.api_paths_delete import API_PATHS_DELETE

def call_PurchaseItem_function(raw_path, event):

    returnString = 'Invalid Function Call'
    PurchaseItem_Path = API_PATHS_DELETE['PurchaseItem']

    if raw_path == PurchaseItem_Path['deletePurchaseItemByPurchaseItemId']['path']:
        returnString = purchase_item.deletePurchaseItemByPurchaseItemId(event)

    return returnString