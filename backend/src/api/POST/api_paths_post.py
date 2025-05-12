from api.table import *

API_PATHS_POST = {
    User_table: {
        "createUser": {
            "path": "/createUser",
            "active": True,
            "input": {"userId": "string"},
            "output": {"user": {"id": "string", "username": "string", "email": "string"}}
        }
    }
}