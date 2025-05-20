import api.GET.Category.get_Category_functions as category
from api.GET.api_paths_get import API_PATHS_GET

def call_Category_function(raw_path, event):

    returnString = 'Invalid Function Call'
    Category_Path = API_PATHS_GET['Category']

    ## Category
    if raw_path == Category_Path['getCategoryByCategoryId']['path']:
        returnString = category.getCategoryByCategoryId(event)
    
    return returnString