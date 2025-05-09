from tools.prod.prodTools import extractData, get_connection

def getUserCollectibleByUserId(event):
    data = extractData(event)
    user_id = data["UserId"]
    if not user_id:
        return {'statusCode': 400, 'body': 'UserId not found'}
    
    connection = get_connection()
    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM UserCollectible WHERE OwnerId = %s", (user_id))
        userCollectibles = cursor.fetchone()
    
    return {'statusCode': 200, 'body': f"{userCollectibles}"}