from tools.prod.prodTools import extractData
import database.CRUD.DELETE.User.delete_User_CRUD_functions as crudFunctions

# def deleteUserByUserId(event):
#     """
#     Deletes a user record by userId.
#     Requires 'userId'.
#     NOTE: This performs a hard delete and ON DELETE CASCADE will remove related records
#     in tables like UserCollectible and CommunityUser.
#     """
#     data = extractData(event)
#     if not data or "userId" not in data:
#         return {'statusCode': 400, 'body': 'userId is required'}

#     user_id = data["userId"]
#     connection = get_connection()
#     if not connection:
#         return {'statusCode': 500, 'body': 'Failed to connect to database'}

#     try:
#         with connection.cursor() as cursor:
#             sql = "DELETE FROM User WHERE userId = %s"
#             cursor.execute(sql, (user_id,))
#             connection.commit()

#             if cursor.rowcount == 0:
#                 return {'statusCode': 404, 'body': 'User not found'}

#         return {'statusCode': 200, 'body': 'User deleted successfully'}
#     except Exception as e:
#         print(f"Database error deleting user: {e}")
#         return {'statusCode': 500, 'body': f'Database error: {e}'}
#     finally:
#         if connection:
#             connection.close()



def deleteUserByUserId(event):
    """
    Deletes a user record by userId.
    Requires 'userId'.
    NOTE: This performs a hard delete and ON DELETE CASCADE will remove related records
    in tables like UserCollectible and CommunityUser.
    """
    data = extractData(event)
    if not data or "userId" not in data:
        return {'statusCode': 400, 'body': 'userId is required'}

    user_id = data["userId"]
    return crudFunctions.deleteUserByUserId(userId=user_id,db=event['db_session'])