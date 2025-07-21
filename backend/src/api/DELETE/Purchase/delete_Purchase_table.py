import api.DELETE.Purchase.delete_Purchase_functions as purchase
from api.DELETE.api_paths_delete import API_PATHS_DELETE

def call_Purchase_function(raw_path, event):

    returnString = 'Invalid Function Call'
    Purchase_Path = API_PATHS_DELETE['Purchase']

    if raw_path == Purchase_Path['deletePurchaseByPurchaseId']['path']:
        returnString = purchase.deletePurchaseByPurchaseId(event)

    return returnString