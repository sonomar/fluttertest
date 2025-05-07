from tools.prod.prodTools import extractData, get_connection

def updateUserByUserId(event):
    data = extractData(event)
    user_id = data["userId"]#event.get('userId')
    username = data["username"]#event.get('username')
    if not user_id or not username:
        return {'statusCode': 400, 'body': 'userId and username are required'}
    
    connection = get_connection()
    with connection.cursor() as cursor:
        sql = "UPDATE User SET username = %s, UpdatedDt = NOW() WHERE userId = %s"
        cursor.execute(sql, (username, user_id))
        connection.commit()
    
    return {'statusCode': 200, 'body': 'User updated successfully'}

def updateUserByUsername(event):
    data = extractData(event)
    usernameNew = data["usernameNew"]
    username = data["username"]
    if not usernameNew or not username:
        return {'statusCode': 400, 'body': 'userId and username are required'}
    
    connection = get_connection()
    with connection.cursor() as cursor:
        sql = "UPDATE User SET username = %s, UpdatedDt = NOW() WHERE username = %s"
        cursor.execute(sql, (usernameNew, username))
        connection.commit()
    
    return {'statusCode': 200, 'body': 'User updated successfully'}
