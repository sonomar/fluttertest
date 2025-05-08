from tools.prod.prodTools import extractData, get_connection
import pymysql

def create_user(event):
    """
    Adds a new user to the database.
    Requires 'email', 'passwordHashed', 'userType'. 'username' and 'deviceId' are optional.
    """
    data = extractData(event)
    # Basic validation for required fields
    if not data or "email" not in data or "passwordHashed" not in data or "userType" not in data:
         return {'statusCode': 400, 'body': 'email, passwordHashed, and userType are required'}

    # Extract data, handle optional fields
    email = data["email"]
    password_hashed = data["passwordHashed"]
    user_type = data["userType"]
    username = data.get("username") # .get() returns None if key is not present
    device_id = data.get("deviceId")
    # 'active', 'createdDt', 'updatedDt' have defaults or are auto-set by DB

    connection = get_connection()
    if not connection:
        return {'statusCode': 500, 'body': 'Failed to connect to database'}

    try:
        with connection.cursor() as cursor:
            # Construct the SQL dynamically based on provided optional fields
            fields = ["email", "passwordHashed", "userType"]
            values = [email, password_hashed, user_type]
            if username is not None:
                fields.append("username")
                values.append(username)
            if device_id is not None:
                fields.append("deviceId")
                values.append(device_id)

            # Include default/auto-set fields explicitly if needed for clarity or specific values
            # fields.extend(["active", "createdDt", "updatedDt"])
            # values.extend([True, pymysql.Timestamp(), pymysql.Timestamp()]) # Example using pymysql.Timestamp()

            sql = f"""
                INSERT INTO User ({', '.join(fields)})
                VALUES ({', '.join(['%s'] * len(values))})
            """
            cursor.execute(sql, tuple(values))
            connection.commit()

            # Optionally fetch the newly created user ID
            new_user_id = cursor.lastrowid

        return {'statusCode': 201, 'body': f'User created successfully: {new_user_id}'}
    except pymysql.err.IntegrityError as e:
         # Handle unique constraint violation (email or username)
         print(f"Integrity error creating user: {e}")
         # Check error code or message for specific constraint
         if 'Duplicate entry' in str(e):
             if 'email' in str(e):
                 return {'statusCode': 409, 'body': 'Conflict: Email already exists'}
             elif 'username' in str(e):
                 return {'statusCode': 409, 'body': 'Conflict: Username already exists'}
             else:
                 return {'statusCode': 409, 'body': f'Conflict: Duplicate entry error - {e}'}
         else:
              return {'statusCode': 409, 'body': f'Integrity error: {e}'}
    except Exception as e:
        # Catch other potential DB errors
        print(f"Database error creating user: {e}")
        return {'statusCode': 500, 'body': f'Database error: {e}'}
    finally:
        if connection:
            connection.close()
