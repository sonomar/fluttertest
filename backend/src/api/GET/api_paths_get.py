from api.table import *

API_PATHS_GET = {
    User_table: {
        "getUserByUserId": {
            "path": "/getUserByUserId",
            "active": True,
            "input": {"userId": "string"},
            "output": {"user": {"id": "string", "username": "string", "email": "string"}}
        },
        "getUserByEmail": {
            "path": "/getUserByEmail",
            "active": True,
            "input": {"email": "string"},
            "output": {"user": {"id": "string", "username": "string", "email": "string"}}
        },
        "getUserByUsername": {
            "path": "/getUserByUsername",
            "active": True,
            "input": {"username": "string"},
            "output": {"user": {"id": "string", "email": "string"}}
        },
        "getUsersByLastLoggedIn": {
            "path": "/getUsersByLastLoggedIn",
            "active": True,
            "input": {"limit": "int"},
            "output": {"users": [{"userId": "string", "lastLogin": "timestamp"}]}
        }
    },

    Collection_table: {
        "getCollectionById": {
            "path": "/getCollectionById",
            "active": True,
            "input": {"collectionId": "string"},
            "output": {"collection": {"id": "string", "name": "string"}}
        },
        "getCollectionByName": {
            "path": "/getCollectionByName",
            "active": True,
            "input": {"name": "string"},
            "output": {"collection": {"id": "string", "name": "string"}}
        }
    },

    Collectible_table: {
        "getCollectibleByCollectibleId": {
            "path": "/getCollectibleByCollectibleId",
            "active": True,
            "input": {"collectibleId": "string"},
            "output": {"collectible": {"id": "string", "name": "string"}}
        },
        "getAllCollectibles": {
            "path": "/getAllCollectibles",
            "active": True,
            "input": {},
            "output": {"collectibles": [{"id": "string", "name": "string"}]}
        },
        "getCollectiblesByCategoryId": {
            "path": "/getCollectiblesByCategoryId",
            "active": True,
            "input": {"categoryId": "string"},
            "output": {"collectibles": [{"id": "string", "name": "string"}]}
        },
        "getCollectiblesByProjectId": {
            "path": "/getCollectiblesByProjectId",
            "active": True,
            "input": {"projectId": "string"},
            "output": {"collectibles": [{"id": "string", "name": "string"}]}
        },
        "getCollectibleByName": {
            "path": "/getCollectibleByName",
            "active": True,
            "input": {"name": "string"},
            "output": {"collectible": {"id": "string", "name": "string"}}
        },
        "getCollectiblesByLabel": {
            "path": "/getCollectiblesByLabel",
            "active": True,
            "input": {"label": "string"},
            "output": {"collectibles": [{"id": "string", "name": "string"}]}
        },
        "getCollectiblesBySponsor": {
            "path": "/getCollectiblesBySponsor",
            "active": True,
            "input": {"sponsorId": "string"},
            "output": {"collectibles": [{"id": "string", "name": "string"}]}
        },
        "getCollectiblesByCollection": {
            "path": "/getCollectiblesByCollection",
            "active": True,
            "input": {"collectionId": "string"},
            "output": {"collectibles": [{"id": "string", "name": "string"}]}
        },
        "getCollectiblesByCommunity": {
            "path": "/getCollectiblesByCommunity",
            "active": True,
            "input": {"communityId": "string"},
            "output": {"collectibles": [{"id": "string", "name": "string"}]}
        }
    },

    Project_table: {
        "getProjectByProjectId": {
            "path": "/getProjectByProjectId",
            "active": True,
            "input": {"projectId": "string"},
            "output": {"project": {"id": "string", "name": "string"}}
        }
    },

    UserCollectible_table: {
        "getUserCollectiblesByUserId": {
            "path": "/getUserCollectiblesByUserId",
            "active": True,
            "input": {"userId": "string"},
            "output": {"collectibles": [{"id": "string", "name": "string"}]}
        }
    }
}
