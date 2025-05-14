import api.DELETE.Category.delete_Category_functions as categoryFunctions
from api.DELETE.api_paths_delete import API_PATHS_DELETE

def call_Category_function(raw_path, event):
    
    returnString = 'Invalid Function Call'
    Category_Path = API_PATHS_DELETE['Category']

    ## Category
    if raw_path == Category_Path['deleteCategoryByCategoryId']['path']:
        returnString = categoryFunctions.deleteCategoryByCategoryId(event)

    return returnString