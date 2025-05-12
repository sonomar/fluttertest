from api.table import *

API_PATHS_DELETE = {
    User_table: {
        "deleteUserByUserId": {
            "path": "/deleteUserByUserId",
            "active": True,
            "input": {"userId": "string"},
            "output": {"user": {"id": "string", "username": "string", "email": "string"}}
        }
    }
}
