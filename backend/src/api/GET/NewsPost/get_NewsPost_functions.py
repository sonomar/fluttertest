# database/CRUD/GET/NewsPost/get_NewsPost_table.py
from tools.prod.prodTools import extractData
import database.CRUD.GET.NewsPost.get_NewsPost_CRUD_functions as crudFunctions

def getNewsPostByNewsPostId(event):
    """
    Retrieves a news post by its newsPostId.
    Requires 'newsPostId' in the request data.
    """
    data = extractData(event)
    if not data or "newsPostId" not in data:
        return {'statusCode': 400, 'body': 'newsPostId is required'}

    news_post_id = data["newsPostId"]
    return crudFunctions.getNewsPostByNewsPostId(newsPostId=news_post_id, db=event['db_session'])

def getNewsPostsByDate(event):
    """
    Retrieves news posts by publication date.
    Requires 'postDateAfter' timestamp in the request data. Optional 'skip' and 'limit' for pagination.
    """
    data = extractData(event)
    skip = 0
    limit = 100

    if not data or "postDateAfter" not in data:
        return {'statusCode': 400, 'body': 'postDateAfter timestamp is required'}

    post_date_after = data["postDateAfter"]

    if "skip" in data:
        skip = data["skip"]
    if "limit" in data:
        limit = data["limit"]

    return crudFunctions.getNewsPostsByDate(postDateAfter=post_date_after, skip=skip, limit=limit, db=event['db_session'])

def getNewsPostsByHeader(event):
    """
    Retrieves news posts by their header.
    Requires 'header' in the request data. Optional 'skip' and 'limit' for pagination.
    """
    data = extractData(event)
    skip = 0
    limit = 100

    if not data or "header" not in data:
        return {'statusCode': 400, 'body': 'header is required'}

    header = data["header"]

    if "skip" in data:
        skip = data["skip"]
    if "limit" in data:
        limit = data["limit"]

    return crudFunctions.getNewsPostsByHeader(header=header, skip=skip, limit=limit, db=event['db_session'])