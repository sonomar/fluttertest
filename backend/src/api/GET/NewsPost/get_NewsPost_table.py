import api.GET.NewsPost.get_NewsPost_functions as newsPost
from api.GET.api_paths_get import API_PATHS_GET

def call_NewsPost_function(raw_path, event):

    returnString = 'Invalid Function Call'
    NewsPost_Path = API_PATHS_GET['NewsPost']

    ## NewsPost
    if raw_path == NewsPost_Path['getNewsPostByNewsPostId']['path']:
        returnString = newsPost.getNewsPostByNewsPostId(event)

    elif raw_path == NewsPost_Path['getNewsPostsByDate']['path']:
        returnString = newsPost.getNewsPostsByDate(event)

    elif raw_path == NewsPost_Path['getNewsPostsByHeader']['path']:
        returnString = newsPost.getNewsPostsByHeader(event)
    
    return returnString