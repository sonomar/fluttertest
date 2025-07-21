import api.GET.Purchase.get_Purchase_functions as purchase
from api.GET.api_paths_get import API_PATHS_GET

def call_Purchase_function(raw_path, event):

    returnString = 'Invalid Function Call'
    Purchase_Path = API_PATHS_GET['Purchase']

    if raw_path == Purchase_Path['getPurchaseByPurchaseId']['path']:
        returnString = purchase.getPurchaseByPurchaseId(event)
    elif raw_path == Purchase_Path['getPurchasesByUserId']['path']:
        returnString = purchase.getPurchasesByUserId(event)

    return returnString