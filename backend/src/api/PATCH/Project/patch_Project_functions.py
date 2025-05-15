from tools.prod.prodTools import extractData
import database.CRUD.PATCH.Project.patch_Project_CRUD_functions as crudFunctions
from database.schema.PATCH.Project.project_schema import ProjectUpdate

def ProjectDataCheck(project: ProjectUpdate, data: any):
    if "name" in data:
        project.name = data["name"]
    if "attributed" in data:
        project.attributed = data["attributed"]
    if "location" in data:
        project.location = data["location"]
    if "active" in data:
        project.active = data["active"]
    return project

def updateProjectByProjectId(event):
    data = extractData(event)
    if not data or "projectId" not in data:
        return {'statusCode': 400, 'body': 'projectId is required'}

    project_id = data["projectId"]
    project = ProjectUpdate()
    project = ProjectDataCheck(project, data)
    return crudFunctions.updateProjectByProjectId(projectId=project_id, project_update_data=project, db=event['db_session'])