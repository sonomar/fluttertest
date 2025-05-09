from tools.prod.prodTools import extractData, get_connection

def getProjectByProjectId(event):
    data = extractData(event)
    project_id = data["ProjectId"]
    if not project_id:
        return {'statusCode': 400, 'body': 'ProjectId not found'}
    
    connection = get_connection()
    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM Project WHERE ProjectId = %s", (project_id))
        project = cursor.fetchone()
    
    return {'statusCode': 200, 'body': f"{project}"}