from tools.prod.prodTools import extractData
import database.CRUD.DELETE.Project.delete_Project_CRUD_functions as crudFunctions



def deleteProjectByProjectId(event):
    """
    Deletes a Project record by projectId.
    Requires 'projectId'.
    """
    data = extractData(event)
    if not data or "projectId" not in data:
        return {'statusCode': 400, 'body': 'projectId is required'}

    project_id = data["projectId"]
    return crudFunctions.deleteProjectByProjectId(projectId=project_id,db=event['db_session'])