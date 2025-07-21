import api.PATCH.PurchaseItem.patch_PurchaseItem_functions as purchase_item
from api.PATCH.api_paths_patch import API_PATHS_PATCH

def call_PurchaseItem_function(raw_path, event):

    returnString = 'Invalid Function Call'
    PurchaseItem_Path = API_PATHS_PATCH['PurchaseItem']

    if raw_path == PurchaseItem_Path['updatePurchaseItemByPurchaseItemId']['path']:
        returnString = purchase_item.updatePurchaseItemByPurchaseItemId(event)

    return returnString