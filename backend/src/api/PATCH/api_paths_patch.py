from api.table import *
from database.schema.GET.User.user_schema import UserResponse # Import schemas
from database.schema.GET.Category.category_schema import CategoryResponse # Import schemas
from database.schema.GET.Community.community_schema import CommunityResponse # Import schemas
from database.schema.GET.Collection.collection_schema import CollectionResponse # Import schemas
from database.schema.GET.Project.project_schema import ProjectResponse # Import schemas
from database.schema.GET.Collectible.collectible_schema import CollectibleResponse # Import schemas
from database.schema.GET.UserCollectible.userCollectible_schema import UserCollectibleResponse # Import schemas
from database.schema.GET.CollectibleSponsor.collectibleSponsor_schema import CollectibleSponsorResponse # Import schemas
from database.schema.GET.Notification.notification_schema import NotificationResponse # Import schemas
from database.schema.GET.CommunityUser.communityUser_schema import CommunityUserResponse # Import schemas
from database.schema.GET.Sponsor.sponsor_schema import SponsorResponse # Import schemas
from database.schema.GET.CommunityChallenge.communityChallenge_schema import CommunityChallengeResponse # Import schemas
from database.schema.GET.Mission.mission_schema import MissionResponse # Import schemas
from database.schema.GET.MissionUser.missionUser_schema import MissionUserResponse # Import schemas
from database.schema.GET.MissionUserData.missionUserData_schema import MissionUserDataResponse # Import schemas
from database.schema.GET.NewsPost.newsPost_schema import NewsPostResponse # Import schemas
from database.schema.GET.NotificationUser.notificationUser_schema import NotificationUserResponse # Import schemas
from database.schema.GET.Distribution.distribution_schema import DistributionResponse # Import schemas
from database.schema.GET.DistributionCode.distributionCode_schema import DistributionCodeResponse # Import schemas
from database.schema.GET.DistributionCodeUser.distributionCodeUser_schema import DistributionCodeUserResponse # Import schemas
from database.schema.GET.DistributionCollectible.distributionCollectible_schema import DistributionCollectibleResponse # Import schemas
from database.schema.GET.MissionType.missionType_schema import MissionTypeResponse


# Import the modules containing your refactored PATCH handler functions
import database.CRUD.PATCH.User.patch_User_CRUD_functions as UserPATCHFunctions
import database.CRUD.PATCH.Category.patch_Category_CRUD_functions as CategoryPATCHFunctions
import database.CRUD.PATCH.Community.patch_Community_CRUD_functions as CommunityPATCHFunctions
import database.CRUD.PATCH.Collection.patch_Collection_CRUD_functions as CollectionPATCHFunctions
import database.CRUD.PATCH.Project.patch_Project_CRUD_functions as ProjectPATCHFunctions
import database.CRUD.PATCH.Collectible.patch_Collectible_CRUD_functions as CollectiblePATCHFunctions
import database.CRUD.PATCH.UserCollectible.patch_UserCollectible_CRUD_functions as UserCollectiblePATCHFunctions
import database.CRUD.PATCH.CommunityUser.patch_CommunityUser_CRUD_functions as CommunityUserPATCHFunctions
import database.CRUD.PATCH.Sponsor.patch_Sponsor_CRUD_functions as SponsorPATCHFunctions
import database.CRUD.PATCH.CollectibleSponsor.patch_CollectibleSponsor_CRUD_functions as CollectibleSponsorPATCHFunctions
import database.CRUD.PATCH.Notification.patch_Notification_CRUD_functions as NotificationPATCHFunctions
import database.CRUD.PATCH.NotificationUser.patch_NotificationUser_CRUD_functions as NotificationUserPATCHFunctions
import database.CRUD.PATCH.NewsPost.patch_NewsPost_CRUD_functions as NewsPostPATCHFunctions
import database.CRUD.PATCH.Mission.patch_Mission_CRUD_functions as MissionPATCHFunctions
import database.CRUD.PATCH.MissionUser.patch_MissionUser_CRUD_functions as MissionUserPATCHFunctions
import database.CRUD.PATCH.MissionUserData.patch_MissionUserData_CRUD_functions as MissionUserDataPATCHFunctions
import database.CRUD.PATCH.CommunityChallenge.patch_CommunityChallenge_CRUD_functions as CommunityChallengePATCHFunctions
import database.CRUD.PATCH.Distribution.patch_Distribution_CRUD_functions as DistributionPATCHFunctions
import database.CRUD.PATCH.DistributionCode.patch_DistributionCode_CRUD_functions as DistributionCodePATCHFunctions
import database.CRUD.PATCH.DistributionCodeUser.patch_DistributionCodeUser_CRUD_functions as DistributionCodeUserPATCHFunctions
import database.CRUD.PATCH.DistributionCollectible.patch_DistributionCollectible_CRUD_functions as DistributionCollectiblePATCHFunctions
import database.CRUD.PATCH.MissionType.patch_MissionType_CRUD_functions as MissionTypePATCHFunctions


# ... import other PATCH function modules

API_PATHS_PATCH = {
    User_table: {
        "updateUserByUserId": {
            "path": "/updateUserByUserId", # Assuming userId becomes a path param
            "pathLocal": "/updateUserByUserId/{userId}", # Assuming userId becomes a path param
            "active": True,
            "handler": UserPATCHFunctions.updateUserByUserId, # <-- Reference
            "response_model": UserResponse # Or maybe a confirmation message schema
             # Input body schema (UserUpdate) and Path param (userId) are in handler signature
        },
         # Add other patch functions once refactored
         "updateUserByUsername": {
            "path": "/updateUserByUsername", # You might want to change this pattern
            "pathLocal": "/updateUserByUsername/{current_username}", # Assuming userId becomes a path param
            "active": True,
            "handler": UserPATCHFunctions.updateUserByUsername, # <-- Reference
            "response_model": UserResponse # Or confirmation
             # Input body schema is in handler signature
        }
    },

    Category_table: {
        "updateCategoryByCategoryId": {
            "path": "/updateCategoryByCategoryId", # Assuming userId becomes a path param
            "pathLocal": "/updateCategoryByCategoryId/{categoryId}", # Assuming userId becomes a path param
            "active": True,
            "handler": CategoryPATCHFunctions.updateCategoryByCategoryId, # <-- Reference
            "response_model": CategoryResponse # Or a simple message schema like {"message": "User updated successfully"}
             # Path param (userId) is in handler signature
        }
         # Add other delete functions once refactored
    },
    Community_table: {
        "updateCommunityByCommunityId": {
            "path": "/updateCommunityByCommunityId", # Assuming userId becomes a path param
            "pathLocal": "/updateCommunityByCommunityId/{communityId}", # Assuming userId becomes a path param
            "active": True,
            "handler": CommunityPATCHFunctions.updateCommunityByCommunityId, # <-- Reference
            "response_model": CommunityResponse # Or a simple message schema like {"message": "User updated successfully"}
             # Path param (userId) is in handler signature
        }
         # Add other delete functions once refactored
    },
    Collection_table: {
        "updateCollectionByCollectionId": {
            "path": "/updateCollectionByCollectionId", # Assuming userId becomes a path param
            "pathLocal": "/updateCollectionByCollectionId/{collectionId}", # Assuming userId becomes a path param
            "active": True,
            "handler": CollectionPATCHFunctions.updateCollectionByCollectionId, # <-- Reference
            "response_model": CollectionResponse # Or a simple message schema like {"message": "User updated successfully"}
             # Path param (userId) is in handler signature
        }
         # Add other delete functions once refactored
    },
    Project_table: {
        "updateProjectByProjectId": {
            "path": "/updateProjectByProjectId", # Assuming userId becomes a path param
            "pathLocal": "/updateProjectByProjectId/{projectId}", # Assuming userId becomes a path param
            "active": True,
            "handler": ProjectPATCHFunctions.updateProjectByProjectId, # <-- Reference
            "response_model": ProjectResponse # Or a simple message schema like {"message": "User updated successfully"}
             # Path param (userId) is in handler signature
        }
         # Add other delete functions once refactored
    },
    Collectible_table: {
        "updateCollectibleByCollectibleId": {
            "path": "/updateCollectibleByCollectibleId", # Assuming userId becomes a path param
            "pathLocal": "/updateCollectibleByCollectibleId/{collectibleId}", # Assuming userId becomes a path param
            "active": True,
            "handler": CollectiblePATCHFunctions.updateCollectibleByCollectibleId, # <-- Reference
            "response_model": CollectibleResponse # Or a simple message schema like {"message": "User updated successfully"}
             # Path param (userId) is in handler signature
        }
         # Add other delete functions once refactored
    },
    UserCollectible_table: {
        "updateUserCollectibleByUserCollectibleId": {
            "path": "/updateUserCollectibleByUserCollectibleId", # Assuming userId becomes a path param
            "pathLocal": "/updateUserCollectibleByUserCollectibleId/{userCollectibleId}", # Assuming userId becomes a path param
            "active": True,
            "handler": UserCollectiblePATCHFunctions.updateUserCollectibleByUserCollectibleId, # <-- Reference
            "response_model": UserCollectibleResponse # Or a simple message schema like {"message": "User updated successfully"}
             # Path param (userId) is in handler signature
        }
         # Add other delete functions once refactored
    },
    CommunityUser_table: {
        "updateCommunityUserByCommunityUserId": {
            "path": "/updateCommunityUserByCommunityUserId", # Assuming userId becomes a path param
            "pathLocal": "/updateCommunityUserByCommunityUserId/{communityUserId}", # Assuming userId becomes a path param
            "active": True,
            "handler": CommunityUserPATCHFunctions.updateCommunityUserByCommunityUserId, # <-- Reference
            "response_model": CommunityUserResponse # Or a simple message schema like {"message": "User updated successfully"}
             # Path param (userId) is in handler signature
        }
         # Add other delete functions once refactored
    },
    Sponsor_table: {
        "updateSponsorBySponsorId": {
            "path": "/updateSponsorBySponsorId", # Assuming userId becomes a path param
            "pathLocal": "/updateSponsorBySponsorId/{sponsorId}", # Assuming userId becomes a path param
            "active": True,
            "handler": SponsorPATCHFunctions.updateSponsorBySponsorId, # <-- Reference
            "response_model": SponsorResponse # Or a simple message schema like {"message": "User updated successfully"}
             # Path param (userId) is in handler signature
        }
         # Add other delete functions once refactored
    },
    CollectibleSponsor_table: {
        "updateCollectibleSponsorByCollectibleSponsorId": {
            "path": "/updateCollectibleSponsorByCollectibleSponsorId", # Assuming userId becomes a path param
            "pathLocal": "/updateCollectibleSponsorByCollectibleSponsorId/{collectibleSponsorId}", # Assuming userId becomes a path param
            "active": True,
            "handler": CollectibleSponsorPATCHFunctions.updateCollectibleSponsorByCollectibleSponsorId, # <-- Reference
            "response_model": CollectibleSponsorResponse # Or a simple message schema like {"message": "User updated successfully"}
             # Path param (userId) is in handler signature
        }
         # Add other delete functions once refactored
    },
    Notification_table: {
        "updateNotificationByNotificationId": {
            "path": "/updateNotificationByNotificationId", # Assuming userId becomes a path param
            "pathLocal": "/updateNotificationByNotificationId/{notificationId}", # Assuming userId becomes a path param
            "active": True,
            "handler": NotificationPATCHFunctions.updateNotificationByNotificationId, # <-- Reference
            "response_model": NotificationResponse # Or a simple message schema like {"message": "User updated successfully"}
             # Path param (userId) is in handler signature
        }
         # Add other delete functions once refactored
    },
    NotificationUser_table: {
        "updateNotificationUserByNotificationUserId": {
            "path": "/updateNotificationUserByNotificationUserId", # Assuming userId becomes a path param
            "pathLocal": "/updateNotificationUserByNotificationUserId/{notificationUserId}", # Assuming userId becomes a path param
            "active": True,
            "handler": NotificationUserPATCHFunctions.updateNotificationUserByNotificationUserId, # <-- Reference
            "response_model": NotificationUserResponse # Or a simple message schema like {"message": "User updated successfully"}
             # Path param (userId) is in handler signature
        }
         # Add other delete functions once refactored
    },
    NewsPost_table: {
        "updateNewsPostByNewsPostId": {
            "path": "/updateNewsPostByNewsPostId", # Assuming userId becomes a path param
            "pathLocal": "/updateNewsPostByNewsPostId/{newsPostId}", # Assuming userId becomes a path param
            "active": True,
            "handler": NewsPostPATCHFunctions.updateNewsPostByNewsPostId, # <-- Reference
            "response_model": NewsPostResponse # Or a simple message schema like {"message": "User updated successfully"}
             # Path param (userId) is in handler signature
        }
         # Add other delete functions once refactored
    },
    Mission_table: {
        "updateMissionByMissionId": {
            "path": "/updateMissionByMissionId", # Assuming userId becomes a path param
            "pathLocal": "/updateMissionByMissionId/{missionId}", # Assuming userId becomes a path param
            "active": True,
            "handler": MissionPATCHFunctions.updateMissionByMissionId, # <-- Reference
            "response_model": MissionResponse # Or a simple message schema like {"message": "User updated successfully"}
             # Path param (userId) is in handler signature
        }
         # Add other delete functions once refactored
    },
    MissionType_table: {
        "updateMissionTypeByMissionTypeId": {
            "path": "/updateMissionTypeByMissionTypeId",
            "pathLocal": "/updateMissionTypeByMissionTypeId/{missionTypeId}",
            "active": True,
            "handler": MissionTypePATCHFunctions.updateMissionTypeByMissionTypeId,
            "response_model": MissionTypeResponse
        }
    },
    MissionUser_table: {
        "updateMissionUserByMissionUserId": {
            "path": "/updateMissionUserByMissionUserId", # Assuming userId becomes a path param
            "pathLocal": "/updateMissionUserByMissionUserId/{missionUserId}", # Assuming userId becomes a path param
            "active": True,
            "handler": MissionUserPATCHFunctions.updateMissionUserByMissionUserId, # <-- Reference
            "response_model": MissionUserResponse # Or a simple message schema like {"message": "User updated successfully"}
             # Path param (userId) is in handler signature
        }
         # Add other delete functions once refactored
    },
    MissionUserData_table: {
        "updateMissionUserDataByMissionUserDataId": {
            "path": "/updateMissionUserDataByMissionUserDataId", # Assuming userId becomes a path param
            "pathLocal": "/updateMissionUserDataByMissionUserDataId/{missionUserDataId}", # Assuming userId becomes a path param
            "active": True,
            "handler": MissionUserDataPATCHFunctions.updateMissionUserDataByMissionUserDataId, # <-- Reference
            "response_model": MissionUserDataResponse # Or a simple message schema like {"message": "User updated successfully"}
             # Path param (userId) is in handler signature
        }
         # Add other delete functions once refactored
    },
    CommunityChallenge_table: {
        "updateCommunityChallengeByCommunityChallengeId": {
            "path": "/updateCommunityChallengeByCommunityChallengeId", # Assuming userId becomes a path param
            "pathLocal": "/updateCommunityChallengeByCommunityChallengeId/{communityChallengeId}", # Assuming userId becomes a path param
            "active": True,
            "handler": CommunityChallengePATCHFunctions.updateCommunityChallengeByCommunityChallengeId, # <-- Reference
            "response_model": CommunityChallengeResponse # Or a simple message schema like {"message": "User updated successfully"}
             # Path param (userId) is in handler signature
        }
         # Add other delete functions once refactored
    },
    Distribution_table: {
        "updateDistributionByDistributionId": {
            "path": "/updateDistributionByDistributionId",
            "pathLocal": "/updateDistributionByDistributionId/{distributionId}",
            "active": True,
            "handler": DistributionPATCHFunctions.updateDistributionByDistributionId,
            "response_model": DistributionResponse
        }
    },
    DistributionCode_table: {
        "updateDistributionCodeByDistributionCodeId": {
            "path": "/updateDistributionCodeByDistributionCodeId",
            "pathLocal": "/updateDistributionCodeByDistributionCodeId/{distributionCodeId}",
            "active": True,
            "handler": DistributionCodePATCHFunctions.updateDistributionCodeByDistributionCodeId,
            "response_model": DistributionCodeResponse
        }
    },
    DistributionCodeUser_table: {
        "updateDistributionCodeUserByDistributionCodeUserId": {
            "path": "/updateDistributionCodeUserByDistributionCodeUserId",
            "pathLocal": "/updateDistributionCodeUserByDistributionCodeUserId/{distributionCodeUserId}",
            "active": True,
            "handler": DistributionCodeUserPATCHFunctions.updateDistributionCodeUserByDistributionCodeUserId,
            "response_model": DistributionCodeUserResponse
        }
    },
    DistributionCollectible_table: {
        "updateDistributionCollectibleByDistributionCollectibleId": {
            "path": "/updateDistributionCollectibleByDistributionCollectibleId",
            "pathLocal": "/updateDistributionCollectibleByDistributionCollectibleId/{distributionCollectibleId}",
            "active": True,
            "handler": DistributionCollectiblePATCHFunctions.updateDistributionCollectibleByDistributionCollectibleId,
            "response_model": DistributionCollectibleResponse
        }
    }
    # Add entries for other tables
}

# Keep old variables for temporary compatibility
# UPDATE_RAW_PATH_updateUserByUserId = '/updateUserByUserId'
# UPDATE_RAW_PATH_updateUserByUserName = '/updateUserByUsername'