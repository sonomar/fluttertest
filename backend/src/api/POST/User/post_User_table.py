from tools.prod.prodTools import extractData, get_connection

def addUser(event):
    data = extractData(event)
    username = data["username"]
    email = data["Email"]
    deviceId = data["deviceId"]
    UserType = data["UserType"]
    if not username:
        return {'statusCode': 400, 'body': 'username is required'}
    
    connection = get_connection()
    with connection.cursor() as cursor:
        sql = "INSERT INTO User (username, Email, deviceId, CreatedDt, UpdatedDt, UserType, Active) VALUES (%s, %s, %s, NOW(), NOW(), %s, TRUE)"
        cursor.execute(sql, (username, email, deviceId, UserType))
        connection.commit()
    
    return {'statusCode': 201, 'body': 'User created successfully'}