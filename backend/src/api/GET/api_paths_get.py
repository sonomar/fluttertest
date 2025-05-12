# src/api/GET/api_paths_get.py
from api.table import *
from typing import List
import database.schemas_common as schemas # Import your schemas
from database.schema.GET.User.user_schema import UserResponse # Import your schemas
# Import the modules containing your refactored handler functions
import database.CRUD.GET.User.get_User_CRUD_functions as UserGETFunctions
#import src.api.GET.Collectible.get_Collectible_functions as CollectibleGETFunctions
#import src.api.GET.Project.get_Project_functions as ProjectGETFunctions
#import src.api.GET.UserCollectible.get_UserCollectible_functions as UserCollectibleGETFunctions
# ... import other GET function modules

API_PATHS_GET = {
    User_table: {
        "getUserByUserId": {
            "path": "/getUserByUserId",
            "active": True,
            "handler": UserGETFunctions.getUserByUserId, # <-- Reference the function
            "response_model": UserResponse # <-- Reference the schema
            # Parameters (userId) are defined in the handler function's signature
        },
        "getUserByEmail": {
            "path": "/getUserByEmail",
            "active": True,
            "handler": UserGETFunctions.getUserByEmail, # <-- Reference the function
            "response_model": UserResponse # <-- Reference the schema
            # Parameters (email) are defined in the handler function's signature
        },
        "getUserByUsername": {
            "path": "/getUserByUsername",
            "active": True,
            "handler": UserGETFunctions.getUserByUsername, # <-- Reference the function
            "response_model": UserResponse # <-- Reference the schema
             # Parameters (username) are defined in the handler function's signature
        },
        "getUsersByLastLoggedIn": {
            "path": "/getUsersByLastLoggedIn",
            "active": True,
            "handler": UserGETFunctions.getUsersByLastLoggedIn, # <-- Reference the function
            "response_model": List[UserResponse] # <-- Reference the schema (list)
            # Parameters (lastLoggedInAfter, skip, limit) are defined in the handler function's signature
        }
    },

    # Collection_table: {
    #     # Assuming you create/refactor Collection GET functions
    #     "getCollectionById": {
    #         "path": "/getCollectionById",
    #         "active": True,
    #         "handler": None, # <-- REPLACE with actual handler function
    #         "response_model": schemas.CollectionResponse # <-- Reference schema
    #     },
    #     "getCollectionByName": {
    #         "path": "/getCollectionByName",
    #         "active": True,
    #         "handler": None, # <-- REPLACE with actual handler function
    #         "response_model": schemas.CollectionResponse # <-- Reference schema
    #     }
    # },

    # Collectible_table: {
    #     "getCollectibleByCollectibleId": {
    #         "path": "/getCollectibleByCollectibleId",
    #         "active": True,
    #         "handler": CollectibleGETFunctions.getCollectibleByCollectibleId, # <-- Reference
    #         "response_model": schemas.CollectibleResponse # <-- Reference
    #     },
    #     "getAllCollectibles": {
    #         "path": "/getAllCollectibles",
    #         "active": True,
    #         "handler": CollectibleGETFunctions.getAllCollectibles, # <-- Reference
    #         "response_model": List[schemas.CollectibleResponse] # <-- Reference (list)
    #     },
    #     "getCollectiblesByCategoryId": {
    #         "path": "/getCollectiblesByCategoryId",
    #         "active": True,
    #         "handler": CollectibleGETFunctions.getCollectiblesByCategoryId, # <-- Reference
    #         "response_model": List[schemas.CollectibleResponse] # <-- Reference (list)
    #     },
    #     "getCollectiblesByProjectId": {
    #         "path": "/getCollectiblesByProjectId",
    #         "active": True,
    #         "handler": CollectibleGETFunctions.getCollectiblesByProjectId, # <-- Reference
    #         "response_model": List[schemas.CollectibleResponse] # <-- Reference (list)
    #     },
    #     # Add references for your other Collectible GET functions once refactored
    #     "getCollectibleByName": {
    #         "path": "/getCollectibleByName",
    #         "active": True,
    #         "handler": None, # <-- REPLACE
    #         "response_model": schemas.CollectibleResponse
    #     },
    #     "getCollectiblesByLabel": {
    #         "path": "/getCollectiblesByLabel",
    #         "active": True,
    #          "handler": None, # <-- REPLACE
    #          "response_model": List[schemas.CollectibleResponse]
    #     },
    #     "getCollectiblesBySponsor": {
    #         "path": "/getCollectiblesBySponsor",
    #         "active": True,
    #         "handler": None, # <-- REPLACE
    #          "response_model": List[schemas.CollectibleResponse]
    #     },
    #     "getCollectiblesByCollection": {
    #         "path": "/getCollectiblesByCollection",
    #         "active": True,
    #          "handler": None, # <-- REPLACE
    #          "response_model": List[schemas.CollectibleResponse]
    #     },
    #     "getCollectiblesByCommunity": {
    #         "path": "/getCollectiblesByCommunity",
    #         "active": True,
    #         "handler": None, # <-- REPLACE
    #          "response_model": List[schemas.CollectibleResponse]
    #     }
    # },

    # Project_table: {
    #     "getProjectByProjectId": {
    #         "path": "/getProjectByProjectId",
    #         "active": True,
    #         "handler": ProjectGETFunctions.getProjectByProjectId, # <-- Reference
    #         "response_model": schemas.ProjectResponse # <-- Reference
    #     }
    # },

    # UserCollectible_table: {
    #     "getUserCollectiblesByUserId": {
    #         "path": "/getUserCollectiblesByUserId",
    #         "active": True,
    #         "handler": UserCollectibleGETFunctions.getUserCollectibleByUserId, # <-- Reference
    #         "response_model": List[schemas.UserCollectibleResponse] # <-- Reference (list)
    #     }
    # }
    # Add entries for other tables (Category, Community, Sponsor, Notification, NewsPost, Mission, MissionUser, MissionUserData, CommunityChallenge, CollectibleSponsor)
    # once you have refactored their GET functions and created their schemas
}