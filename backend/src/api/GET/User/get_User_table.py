from tools.prod.prodTools import extractData, get_connection

def getUserByUserId(event):
    """
    Retrieves a user by their userId.
    Requires 'userId' in the request data.
    """
    data = extractData(event)
    if not data or "userId" not in data:
        return {'statusCode': 400, 'body': 'userId is required'}

    user_id = data["userId"]
    connection = get_connection()
    if not connection:
        return {'statusCode': 500, 'body': 'Failed to connect to database'}

    try:
        with connection.cursor() as cursor:
            sql = "SELECT * FROM User WHERE userId = %s"
            cursor.execute(sql, (user_id,))
            user = cursor.fetchone() # userId is PRIMARY KEY, so fetchone

        if user:
            # For a proper API, you'd convert tuple/dict to JSON string
            return {'statusCode': 200, 'body': f"{user}"} # Using json.dumps for better API practice
        else:
            return {'statusCode': 404, 'body': 'User not found'}
    except Exception as e:
        print(f"Database error fetching user by ID: {e}")
        return {'statusCode': 500, 'body': f'Database error: {e}'}
    finally:
        if connection:
            connection.close()

def getUserByEmail(event):
    """
    Retrieves a user by their email address.
    Requires 'email' in the request data.
    """
    data = extractData(event)
    if not data or "email" not in data:
        return {'statusCode': 400, 'body': 'email is required'}

    email = data["email"]
    connection = get_connection()
    if not connection:
        return {'statusCode': 500, 'body': 'Failed to connect to database'}

    try:
        with connection.cursor() as cursor:
            # email is UNIQUE
            sql = "SELECT * FROM User WHERE email = %s"
            cursor.execute(sql, (email,))
            user = cursor.fetchone()

        if user:
            return {'statusCode': 200, 'body': f"{user}"}
        else:
            return {'statusCode': 404, 'body': 'User not found'}
    except Exception as e:
        print(f"Database error fetching user by email: {e}")
        return {'statusCode': 500, 'body': f'Database error: {e}'}
    finally:
        if connection:
            connection.close()

def getUserByUsername(event):
    """
    Retrieves a user by their username.
    Requires 'username' in the request data.
    """
    data = extractData(event)
    if not data or "username" not in data:
        return {'statusCode': 400, 'body': 'username is required'}

    email = data["username"]
    connection = get_connection()
    if not connection:
        return {'statusCode': 500, 'body': 'Failed to connect to database'}

    try:
        with connection.cursor() as cursor:
            # username is UNIQUE
            sql = "SELECT * FROM User WHERE username = %s"
            cursor.execute(sql, (email,))
            user = cursor.fetchone()

        if user:
            return {'statusCode': 200, 'body': f"{user}"}
        else:
            return {'statusCode': 404, 'body': 'User not found'}
    except Exception as e:
        print(f"Database error fetching user by username: {e}")
        return {'statusCode': 500, 'body': f'Database error: {e}'}
    finally:
        if connection:
            connection.close()

def getUsersByLastLoggedIn(event):
    """
    Retrieves users who logged in after or at a specific timestamp.
    Requires 'lastLoggedInAfter' timestamp in the request data.
    """
    data = extractData(event)
    # Consider adding validation that lastLoggedInAfter is a valid timestamp format
    if not data or "lastLoggedInAfter" not in data:
        return {'statusCode': 400, 'body': 'lastLoggedInAfter timestamp is required'}

    last_logged_in_after = data["lastLoggedInAfter"]
    connection = get_connection()
    if not connection:
        return {'statusCode': 500, 'body': 'Failed to connect to database'}

    try:
        with connection.cursor() as cursor:
            # Use >= to get users logged in ON or AFTER the timestamp
            sql = "SELECT * FROM User WHERE lastLoggedIn >= %s"
            cursor.execute(sql, (last_logged_in_after,))
            users = cursor.fetchall()

        return {'statusCode': 200, 'body': f"{users}"}
    except Exception as e:
        print(f"Database error fetching users by last logged in: {e}")
        return {'statusCode': 500, 'body': f'Database error: {e}'}
    finally:
        if connection:
            connection.close()