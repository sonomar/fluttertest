import api.DELETE.NewsPost.delete_NewsPost_functions as newsPostFunctions
from api.DELETE.api_paths_delete import API_PATHS_DELETE

def call_NewsPost_function(raw_path, event):
    
    returnString = 'Invalid Function Call'
    NewsPost_Path = API_PATHS_DELETE['NewsPost']

    ## NewsPost
    if raw_path == NewsPost_Path['deleteNewsPostByNewsPostId']['path']:
        returnString = newsPostFunctions.deleteNewsPostByNewsPostId(event)

    return returnString