from tools.prod.prodTools import extractData
import database.CRUD.DELETE.NewsPost.delete_NewsPost_CRUD_functions as crudFunctions



def deleteNewsPostByNewsPostId(event):
    """
    Deletes a NewsPost record by newsPostId.
    Requires 'newsPostId'.
    """
    data = extractData(event)
    if not data or "newsPostId" not in data:
        return {'statusCode': 400, 'body': 'newsPostId is required'}

    newsPost_id = data["newsPostId"]
    return crudFunctions.deleteNewsPostByNewsPostId(newsPostId=newsPost_id,db=event['db_session'])