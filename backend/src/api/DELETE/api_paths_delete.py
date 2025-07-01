# src/api/DELETE/api_path_delete.py
from api.table import *
from typing import Dict
#from database.schema import schemas # Import schemas
# Import the modules containing your refactored DELETE handler functions
import database.CRUD.DELETE.User.delete_User_CRUD_functions as UserDELETEFunctions
import database.CRUD.DELETE.Category.delete_Category_CRUD_functions as CategoryDELETEFunctions
import database.CRUD.DELETE.Community.delete_Community_CRUD_functions as CommunityDELETEFunctions
import database.CRUD.DELETE.Collection.delete_Collection_CRUD_functions as CollectionDELETEFunctions
import database.CRUD.DELETE.Project.delete_Project_CRUD_functions as ProjectDELETEFunctions
import database.CRUD.DELETE.Collectible.delete_Collectible_CRUD_functions as CollectibleDELETEFunctions
import database.CRUD.DELETE.UserCollectible.delete_UserCollectible_CRUD_functions as UserCollectibleDELETEFunctions
import database.CRUD.DELETE.CommunityUser.delete_CommunityUser_CRUD_functions as CommunityUserDELETEFunctions
import database.CRUD.DELETE.Sponsor.delete_Sponsor_CRUD_functions as SponsorDELETEFunctions
import database.CRUD.DELETE.CollectibleSponsor.delete_CollectibleSponsor_CRUD_functions as CollectibleSponsorDELETEFunctions
import database.CRUD.DELETE.Notification.delete_Notification_CRUD_functions as NotificationDELETEFunctions
import database.CRUD.DELETE.NotificationUser.delete_NotificationUser_CRUD_functions as NotificationUserDELETEFunctions
import database.CRUD.DELETE.NewsPost.delete_NewsPost_CRUD_functions as NewsPostDELETEFunctions
import database.CRUD.DELETE.Mission.delete_Mission_CRUD_functions as MissionDELETEFunctions
import database.CRUD.DELETE.MissionUser.delete_MissionUser_CRUD_functions as MissionUserDELETEFunctions
import database.CRUD.DELETE.MissionUserData.delete_MissionUserData_CRUD_functions as MissionUserDataDELETEFunctions
import database.CRUD.DELETE.CommunityChallenge.delete_CommunityChallenge_CRUD_functions as CommunityChallengeDELETEFunctions
import database.CRUD.DELETE.Distribution.delete_Distribution_CRUD_functions as DistributionDELETEFunctions
import database.CRUD.DELETE.DistributionCode.delete_DistributionCode_CRUD_functions as DistributionCodeDELETEFunctions
import database.CRUD.DELETE.DistributionCodeUser.delete_DistributionCodeUser_CRUD_functions as DistributionCodeUserDELETEFunctions
import database.CRUD.DELETE.DistributionCollectible.delete_DistributionCollectible_CRUD_functions as DistributionCollectibleDELETEFunctions

# ... import other DELETE function modules


API_PATHS_DELETE = {
    User_table: {
        "deleteUserByUserId": {
            "path": "/deleteUserByUserId", # Assuming userId becomes a path param
            "pathLocal": "/deleteUserByUserId/{userId}", # Assuming userId becomes a path param
            "active": True,
            "handler": UserDELETEFunctions.deleteUserByUserId, # <-- Reference
            "response_model": Dict[str, str] # Or a simple message schema like {"message": "User deleted successfully"}
             # Path param (userId) is in handler signature
        }
         # Add other delete functions once refactored
    },
    Category_table: {
        "deleteCategoryByCategoryId": {
            "path": "/deleteCategoryByCategoryId", # Assuming userId becomes a path param
            "pathLocal": "/deleteCategoryByCategoryId/{categoryId}", # Assuming userId becomes a path param
            "active": True,
            "handler": CategoryDELETEFunctions.deleteCategoryByCategoryId, # <-- Reference
            "response_model": Dict[str, str] # Or a simple message schema like {"message": "User deleted successfully"}
             # Path param (userId) is in handler signature
        }
         # Add other delete functions once refactored
    },
    Community_table: {
        "deleteCommunityByCommunityId": {
            "path": "/deleteCommunityByCommunityId", # Assuming userId becomes a path param
            "pathLocal": "/deleteCommunityByCommunityId/{communityId}", # Assuming userId becomes a path param
            "active": True,
            "handler": CommunityDELETEFunctions.deleteCommunityByCommunityId, # <-- Reference
            "response_model": Dict[str, str] # Or a simple message schema like {"message": "User deleted successfully"}
             # Path param (userId) is in handler signature
        }
         # Add other delete functions once refactored
    },
    Collection_table: {
        "deleteCollectionByCollectionId": {
            "path": "/deleteCollectionByCollectionId", # Assuming userId becomes a path param
            "pathLocal": "/deleteCollectionByCollectionId/{collectionId}", # Assuming userId becomes a path param
            "active": True,
            "handler": CollectionDELETEFunctions.deleteCollectionByCollectionId, # <-- Reference
            "response_model": Dict[str, str] # Or a simple message schema like {"message": "User deleted successfully"}
             # Path param (userId) is in handler signature
        }
         # Add other delete functions once refactored
    },
    Project_table: {
        "deleteProjectByProjectId": {
            "path": "/deleteProjectByProjectId", # Assuming userId becomes a path param
            "pathLocal": "/deleteProjectByProjectId/{projectId}", # Assuming userId becomes a path param
            "active": True,
            "handler": ProjectDELETEFunctions.deleteProjectByProjectId, # <-- Reference
            "response_model": Dict[str, str] # Or a simple message schema like {"message": "User deleted successfully"}
             # Path param (userId) is in handler signature
        }
         # Add other delete functions once refactored
    },
    Collectible_table: {
        "deleteCollectibleByCollectibleId": {
            "path": "/deleteCollectibleByCollectibleId", # Assuming userId becomes a path param
            "pathLocal": "/deleteCollectibleByCollectibleId/{collectibleId}", # Assuming userId becomes a path param
            "active": True,
            "handler": CollectibleDELETEFunctions.deleteCollectibleByCollectibleId, # <-- Reference
            "response_model": Dict[str, str] # Or a simple message schema like {"message": "User deleted successfully"}
             # Path param (userId) is in handler signature
        }
         # Add other delete functions once refactored
    },
    UserCollectible_table: {
        "deleteUserCollectibleByUserCollectibleId": {
            "path": "/deleteUserCollectibleByUserCollectibleId", # Assuming userId becomes a path param
            "pathLocal": "/deleteUserCollectibleByUserCollectibleId/{userCollectibleId}", # Assuming userId becomes a path param
            "active": True,
            "handler": UserCollectibleDELETEFunctions.deleteUserCollectibleByUserCollectibleId, # <-- Reference
            "response_model": Dict[str, str] # Or a simple message schema like {"message": "User deleted successfully"}
             # Path param (userId) is in handler signature
        }
         # Add other delete functions once refactored
    },
    CommunityUser_table: {
        "deleteCommunityUserByCommunityUserId": {
            "path": "/deleteCommunityUserByCommunityUserId", # Assuming userId becomes a path param
            "pathLocal": "/deleteCommunityUserByCommunityUserId/{communityUserId}", # Assuming userId becomes a path param
            "active": True,
            "handler": CommunityUserDELETEFunctions.deleteCommunityUserByCommunityUserId, # <-- Reference
            "response_model": Dict[str, str] # Or a simple message schema like {"message": "User deleted successfully"}
             # Path param (userId) is in handler signature
        }
         # Add other delete functions once refactored
    },
    Sponsor_table: {
        "deleteSponsorBySponsorId": {
            "path": "/deleteSponsorBySponsorId", # Assuming userId becomes a path param
            "pathLocal": "/deleteSponsorBySponsorId/{sponsorId}", # Assuming userId becomes a path param
            "active": True,
            "handler": SponsorDELETEFunctions.deleteSponsorBySponsorId, # <-- Reference
            "response_model": Dict[str, str] # Or a simple message schema like {"message": "User deleted successfully"}
             # Path param (userId) is in handler signature
        }
         # Add other delete functions once refactored
    },
    CollectibleSponsor_table: {
        "deleteCollectibleSponsorByCollectibleSponsorId": {
            "path": "/deleteCollectibleSponsorByCollectibleSponsorId", # Assuming userId becomes a path param
            "pathLocal": "/deleteCollectibleSponsorByCollectibleSponsorId/{collectibleSponsorId}", # Assuming userId becomes a path param
            "active": True,
            "handler": CollectibleSponsorDELETEFunctions.deleteCollectibleSponsorByCollectibleSponsorId, # <-- Reference
            "response_model": Dict[str, str] # Or a simple message schema like {"message": "User deleted successfully"}
             # Path param (userId) is in handler signature
        }
         # Add other delete functions once refactored
    },
    Notification_table: {
        "deleteNotificationByNotificationId": {
            "path": "/deleteNotificationByNotificationId", # Assuming userId becomes a path param
            "pathLocal": "/deleteNotificationByNotificationId/{notificationId}", # Assuming userId becomes a path param
            "active": True,
            "handler": NotificationDELETEFunctions.deleteNotificationByNotificationId, # <-- Reference
            "response_model": Dict[str, str] # Or a simple message schema like {"message": "User deleted successfully"}
             # Path param (userId) is in handler signature
        }
         # Add other delete functions once refactored
    },
    NotificationUser_table: {
        "deleteNotificationUserByNotificationUserId": {
            "path": "/deleteNotificationUserByNotificationUserId", # Assuming userId becomes a path param
            "pathLocal": "/deleteNotificationUserByNotificationUserId/{notificationUserId}", # Assuming userId becomes a path param
            "active": True,
            "handler": NotificationUserDELETEFunctions.deleteNotificationUserByNotificationUserId, # <-- Reference
            "response_model": Dict[str, str] # Or a simple message schema like {"message": "User deleted successfully"}
             # Path param (userId) is in handler signature
        }
         # Add other delete functions once refactored
    },
    NewsPost_table: {
        "deleteNewsPostByNewsPostId": {
            "path": "/deleteNewsPostByNewsPostId", # Assuming userId becomes a path param
            "pathLocal": "/deleteNewsPostByNewsPostId/{newsPostId}", # Assuming userId becomes a path param
            "active": True,
            "handler": NewsPostDELETEFunctions.deleteNewsPostByNewsPostId, # <-- Reference
            "response_model": Dict[str, str] # Or a simple message schema like {"message": "User deleted successfully"}
             # Path param (userId) is in handler signature
        }
         # Add other delete functions once refactored
    },
    Mission_table: {
        "deleteMissionByMissionId": {
            "path": "/deleteMissionByMissionId", # Assuming userId becomes a path param
            "pathLocal": "/deleteMissionByMissionId/{missionId}", # Assuming userId becomes a path param
            "active": True,
            "handler": MissionDELETEFunctions.deleteMissionByMissionId, # <-- Reference
            "response_model": Dict[str, str] # Or a simple message schema like {"message": "User deleted successfully"}
             # Path param (userId) is in handler signature
        }
         # Add other delete functions once refactored
    },
    MissionUser_table: {
        "deleteMissionUserByMissionUserId": {
            "path": "/deleteMissionUserByMissionUserId", # Assuming userId becomes a path param
            "pathLocal": "/deleteMissionUserByMissionUserId/{missionUserId}", # Assuming userId becomes a path param
            "active": True,
            "handler": MissionUserDELETEFunctions.deleteMissionUserByMissionUserId, # <-- Reference
            "response_model": Dict[str, str] # Or a simple message schema like {"message": "User deleted successfully"}
             # Path param (userId) is in handler signature
        }
         # Add other delete functions once refactored
    },
    MissionUserData_table: {
        "deleteMissionUserDataByMissionUserDataId": {
            "path": "/deleteMissionUserDataByMissionUserDataId", # Assuming userId becomes a path param
            "pathLocal": "/deleteMissionUserDataByMissionUserDataId/{missionUserDataId}", # Assuming userId becomes a path param
            "active": True,
            "handler": MissionUserDataDELETEFunctions.deleteMissionUserDataByMissionUserDataId, # <-- Reference
            "response_model": Dict[str, str] # Or a simple message schema like {"message": "User deleted successfully"}
             # Path param (userId) is in handler signature
        }
         # Add other delete functions once refactored
    },
    CommunityChallenge_table: {
        "deleteCommunityChallengeByCommunityChallengeId": {
            "path": "/deleteCommunityChallengeByCommunityChallengeId", # Assuming userId becomes a path param
            "pathLocal": "/deleteCommunityChallengeByCommunityChallengeId/{communityChallengeId}", # Assuming userId becomes a path param
            "active": True,
            "handler": CommunityChallengeDELETEFunctions.deleteCommunityChallengeByCommunityChallengeId, # <-- Reference
            "response_model": Dict[str, str] # Or a simple message schema like {"message": "User deleted successfully"}
             # Path param (userId) is in handler signature
        }
         # Add other delete functions once refactored
    },
    Distribution_table: {
        "deleteDistributionByDistributionId": {
            "path": "/deleteDistributionByDistributionId",
            "pathLocal": "/deleteDistributionByDistributionId/{distributionId}",
            "active": True,
            "handler": DistributionDELETEFunctions.deleteDistributionByDistributionId,
            "response_model": Dict[str, str]
        }
    },
    DistributionCode_table: {
        "deleteDistributionCodeByDistributionCodeId": {
            "path": "/deleteDistributionCodeByDistributionCodeId",
            "pathLocal": "/deleteDistributionCodeByDistributionCodeId/{distributionCodeId}",
            "active": True,
            "handler": DistributionCodeDELETEFunctions.deleteDistributionCodeByDistributionCodeId,
            "response_model": Dict[str, str]
        }
    },
    DistributionCodeUser_table: {
        "deleteDistributionCodeUserByDistributionCodeUserId": {
            "path": "/deleteDistributionCodeUserByDistributionCodeUserId",
            "pathLocal": "/deleteDistributionCodeUserByDistributionCodeUserId/{distributionCodeUserId}",
            "active": True,
            "handler": DistributionCodeUserDELETEFunctions.deleteDistributionCodeUserByDistributionCodeUserId,
            "response_model": Dict[str, str]
        }
    },
    DistributionCollectible_table: {
        "deleteDistributionCollectibleByDistributionCollectibleId": {
            "path": "/deleteDistributionCollectibleByDistributionCollectibleId",
            "pathLocal": "/deleteDistributionCollectibleByDistributionCollectibleId/{distributionCollectibleId}",
            "active": True,
            "handler": DistributionCollectibleDELETEFunctions.deleteDistributionCollectibleByDistributionCollectibleId,
            "response_model": Dict[str, str]
        }
    }
    # Add entries for other tables
}

# Keep old variables for temporary compatibility
# DELETE_RAW_PATH_deleteUserByUserId = '/deleteUserByUserId'
