from tools.prod.prodTools import extractData
import database.CRUD.PATCH.User.patch_User_CRUD_functions as crudFunctions
from database.schema.PATCH.User.user_schema import UserUpdate
from database.models import UserTypeEnum
import datetime


# def updateUserByUserId(event):
#     """
#     Updates user information based on userId.
#     Requires 'userId' and at least one field to update (e.g., 'username', 'email', 'active', etc.)
#     """
#     data = extractData(event)
#     if not data or "userId" not in data:
#         return {'statusCode': 400, 'body': 'userId is required'}

#     user_id = data["userId"]
#     update_fields = {}
#     # Check for fields that can be updated and add them to a dict
#     # Ensure keys match database column names
#     if "active" in data:
#         update_fields["active"] = data["active"]
#     if "email" in data:
#         update_fields["email"] = data["email"]
#     if "userRank" in data: # JSON field
#         # pymysql handles serializing Python dict/list to JSON string
#         update_fields["userRank"] = data["userRank"]
#     if "username" in data:
#         update_fields["username"] = data["username"]
#     if "passwordHashed" in data:
#         update_fields["passwordHashed"] = data["passwordHashed"]
#     if "profileImg" in data:
#         update_fields["profileImg"] = data["profileImg"]
#     if "authToken" in data: # Note: authToken is TEXT
#         update_fields["authToken"] = data["authToken"]
#     if "deviceId" in data:
#         update_fields["deviceId"] = data["deviceId"]
#     if "userType" in data: # ENUM type
#         # Consider validating userType against allowed ENUM values if necessary
#         update_fields["userType"] = data["userType"]
#     if "lastLoggedIn" in data: # TIMESTAMP
#         # Consider validating timestamp format
#         update_fields["lastLoggedIn"] = data["lastLoggedIn"]

#     if not update_fields:
#         return {'statusCode': 400, 'body': 'No fields provided for update'}

#     connection = get_connection()
#     if not connection:
#         return {'statusCode': 500, 'body': 'Failed to connect to database'}

#     try:
#         with connection.cursor() as cursor:
#             # Dynamically build the SET part of the SQL query
#             set_clauses = []
#             values = []
#             for field, value in update_fields.items():
#                 set_clauses.append(f"`{field}` = %s") # Use backticks for column names
#                 values.append(value)

#             # Add updatedDt = NOW()
#             set_clauses.append("updatedDt = NOW()")

#             sql = f"""
#                 UPDATE User
#                 SET {', '.join(set_clauses)}
#                 WHERE userId = %s
#             """
#             values.append(user_id) # Add userId to the end of values

#             cursor.execute(sql, tuple(values))
#             connection.commit()

#             # Check if any row was actually updated
#             if cursor.rowcount == 0:
#                  # This could mean the user was not found OR the provided values were the same
#                  # as the existing values. Returning 404 is common if the primary key isn't found.
#                  # If rowcount is 0 and userId exists, it means no effective change.
#                  # You might want to fetch the user first to distinguish.
#                  # For simplicity, returning 404 if no rows affected.
#                  return {'statusCode': 404, 'body': 'User not found or no changes made'}

#         return {'statusCode': 200, 'body': 'User updated successfully'}
#     except pymysql.err.IntegrityError as e:
#          # Handle unique constraint violation (email or username)
#          print(f"Integrity error updating user: {e}")
#          if 'Duplicate entry' in str(e):
#              if 'email' in str(e):
#                  return {'statusCode': 409, 'body': 'Conflict: Email already exists'}
#              elif 'username' in str(e):
#                  return {'statusCode': 409, 'body': 'Conflict: Username already exists'}
#              else:
#                  return {'statusCode': 409, 'body': f'Conflict: Duplicate entry error - {e}'}
#          else:
#               return {'statusCode': 409, 'body': f'Integrity error: {e}'}
#     except Exception as e:
#         print(f"Database error updating user: {e}")
#         return {'statusCode': 500, 'body': f'Database error: {e}'}
#     finally:
#         if connection:
#             connection.close()

# def updateUserByUsername(event):
#     data = extractData(event)
#     usernameNew = data["usernameNew"]
#     username = data["username"]
#     if not usernameNew or not username:
#         return {'statusCode': 400, 'body': 'userId and username are required'}
    
#     connection = get_connection()
#     with connection.cursor() as cursor:
#         sql = "UPDATE User SET username = %s, WHERE username = %s"
#         cursor.execute(sql, (usernameNew, username))
#         connection.commit()
    
#     return {'statusCode': 200, 'body': 'User updated successfully'}

def UserDataCheck(user: UserUpdate, data: any):
        # Check for fields that can be updated and add them to a dict
    # Ensure keys match database column names
    if "active" in data:
        user.active = data["active"]
    if "email" in data:
        user.email = data["email"]
    if "userRank" in data: # JSON field
        # pymysql handles serializing Python dict/list to JSON string
        user.userRank = data["userRank"]
    if "username" in data:
        user.username = data["username"]
    if "passwordHashed" in data:
        user.passwordHashed = data["passwordHashed"]
    if "profileImg" in data:
        user.profileImg = data["profileImg"]
    if "authToken" in data: # Note: authToken is TEXT
        user.authToken = data["authToken"]
    if "deviceId" in data:
        user.deviceId = data["deviceId"]
    if "userType" in data: # ENUM type
        # Consider validating userType against allowed ENUM values if necessary
        user.userType = UserTypeEnum(data["userType"])
    if "lastLoggedIn" in data:
        if isinstance(data["lastLoggedIn"], str):
            user.lastLoggedIn = datetime.datetime.fromisoformat(data["lastLoggedIn"])
        user.lastLoggedIn = data["lastLoggedIn"]
    if "usernameNew" in data: # TIMESTAMP
        # Consider validating timestamp format
        user.username = data["usernameNew"]
    if "score" in data:
        user.score = data["score"]
    if "cognitoUsername" in data:
        user.cognitoUsername = data["cognitoUsername"]
    if "isOnBlockchain" in data:
        user.isOnBlockchain = data["isOnBlockchain"]
    if "blockchainUserAddress" in data:
        user.blockchainUserAddress = data["blockchainUserAddress"]
    if "pushToken" in data:
        user.pushToken = data["pushToken"]
    if "authData" in data:
        user.authData = data["authData"]

    return user


def updateUserByUserId(event):
    """
    Updates user information based on userId.
    Requires 'userId' and at least one field to update (e.g., 'username', 'email', 'active', etc.)
    """
    data = extractData(event)
    if not data or "userId" not in data:
        return {'statusCode': 400, 'body': 'userId is required'}

    user_id = data["userId"]
    user = UserUpdate()

    user = UserDataCheck(user, data)

    if not data or "userId" not in data:
        return {'statusCode': 400, 'body': 'userId is required'}

    user_id = data["userId"]
    
    return crudFunctions.updateUserByUserId(userId=user_id, user_update_data=user, db=event['db_session'])


def updateUserByUsername(event):
    data = extractData(event)
    username = data["username"]
    user = UserUpdate()
    user = UserDataCheck(user, data)
    if not username:
        return {'statusCode': 400, 'body': 'username are required'}
    
    return crudFunctions.updateUserByUsername(current_username=username, user_update_data=user, db=event['db_session'])
