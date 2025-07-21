import api.PATCH.Purchase.patch_Purchase_functions as purchase
from api.PATCH.api_paths_patch import API_PATHS_PATCH

def call_Purchase_function(raw_path, event):

    returnString = 'Invalid Function Call'
    Purchase_Path = API_PATHS_PATCH['Purchase']

    if raw_path == Purchase_Path['updatePurchaseByPurchaseId']['path']:
        returnString = purchase.updatePurchaseByPurchaseId(event)

    return returnString