from tools.prod.prodTools import extractData, get_connection

def getAllCollectibles(event):
    connection = get_connection()
    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM Collectible WHERE Active = TRUE")
        collectibles = cursor.fetchall()
    
    return {'statusCode': 200, 'body': f"{collectibles}"}

def getCollectiblesByCategoryId(event):
    data = extractData(event)
    category_id = data["CategoryId"]
    if not category_id:
        return {'statusCode': 400, 'body': 'CategoryId is required'}
    
    connection = get_connection()
    with connection.cursor() as cursor:
        sql = "SELECT * FROM Collectible WHERE CategoryId = %s AND Active = TRUE"
        cursor.execute(sql, (category_id))
        collectibles = cursor.fetchall()
    
    return {'statusCode': 200, 'body': f"{collectibles}"}

def getCollectiblesByProjectId(event):
    data = extractData(event)
    project_id = data["ProjectId"]
    if not project_id:
        return {'statusCode': 400, 'body': 'projectId is required'}
    
    connection = get_connection()
    with connection.cursor() as cursor:
        sql = "SELECT * FROM Collectible WHERE ProjectId = %s AND Active = TRUE"
        cursor.execute(sql, (project_id))
        collectibles = cursor.fetchall()
    
    return {'statusCode': 200, 'body': f"{collectibles}"}

def getCollectibleByCollectibleId(event):
    data = extractData(event)
    collectible_id = data["CollectibleId"]
    if not collectible_id:
        return {'statusCode': 400, 'body': 'collectibleId is required'}
    connection = get_connection()
    with connection.cursor() as cursor:
        sql = "SELECT * FROM Collectible WHERE CollectibleId = %s AND Active = TRUE"
        cursor.execute(sql, (collectible_id))
        collectible = cursor.fetchone()
    
    return {'statusCode': 200, 'body': f"{collectible}"}
