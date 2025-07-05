# src/api/GET/api_paths_get.py
from api.table import *
from typing import List

# Import your GET response schemas
from database.schema.GET.User.user_schema import UserResponse
from database.schema.GET.Category.category_schema import CategoryResponse
from database.schema.GET.Collection.collection_schema import CollectionResponse
from database.schema.GET.Collectible.collectible_schema import CollectibleResponse
from database.schema.GET.CollectibleSponsor.collectibleSponsor_schema import CollectibleSponsorResponse
from database.schema.GET.Community.community_schema import CommunityResponse
from database.schema.GET.CommunityChallenge.communityChallenge_schema import CommunityChallengeResponse
from database.schema.GET.CommunityUser.communityUser_schema import CommunityUserResponse
from database.schema.GET.Mission.mission_schema import MissionResponse
from database.schema.GET.MissionUser.missionUser_schema import MissionUserResponse
from database.schema.GET.MissionUserData.missionUserData_schema import MissionUserDataResponse
from database.schema.GET.NewsPost.newsPost_schema import NewsPostResponse
from database.schema.GET.Notification.notification_schema import NotificationResponse
from database.schema.GET.NotificationUser.notificationUser_schema import NotificationUserResponse
from database.schema.GET.Project.project_schema import ProjectResponse
from database.schema.GET.Sponsor.sponsor_schema import SponsorResponse
from database.schema.GET.UserCollectible.userCollectible_schema import UserCollectibleResponse

from database.schema.GET.Distribution.distribution_schema import DistributionResponse
from database.schema.GET.DistributionCode.distributionCode_schema import DistributionCodeResponse
from database.schema.GET.DistributionCodeUser.distributionCodeUser_schema import DistributionCodeUserResponse
from database.schema.GET.DistributionCollectible.distributionCollectible_schema import DistributionCollectibleResponse


# Import the modules containing your refactored GET handler functions
import database.CRUD.GET.User.get_User_CRUD_functions as UserGETFunctions
import database.CRUD.GET.Category.get_Category_CRUD_functions as CategoryGETFunctions
import database.CRUD.GET.Collection.get_Collection_CRUD_functions as CollectionGETFunctions
import database.CRUD.GET.Collectible.get_Collectible_CRUD_functions as CollectibleGETFunctions
import database.CRUD.GET.CollectibleSponsor.get_CollectibleSponsor_CRUD_functions as CollectibleSponsorGETFunctions
import database.CRUD.GET.Community.get_Community_CRUD_functions as CommunityGETFunctions
import database.CRUD.GET.CommunityChallenge.get_CommunityChallenge_CRUD_functions as CommunityChallengeGETFunctions
import database.CRUD.GET.CommunityUser.get_CommunityUser_CRUD_functions as CommunityUserGETFunctions
import database.CRUD.GET.Mission.get_Mission_CRUD_functions as MissionGETFunctions
import database.CRUD.GET.MissionUser.get_MissionUser_CRUD_functions as MissionUserGETFunctions
import database.CRUD.GET.MissionUserData.get_MissionUserData_CRUD_functions as MissionUserDataGETFunctions
import database.CRUD.GET.NewsPost.get_NewsPost_CRUD_functions as NewsPostGETFunctions
import database.CRUD.GET.Notification.get_Notification_CRUD_functions as NotificationGETFunctions
import database.CRUD.GET.NotificationUser.get_NotificationUser_CRUD_functions as NotificationUserGETFunctions
import database.CRUD.GET.Project.get_Project_CRUD_functions as ProjectGETFunctions
import database.CRUD.GET.Sponsor.get_Sponsor_CRUD_functions as SponsorGETFunctions
import database.CRUD.GET.UserCollectible.get_UserCollectible_CRUD_functions as UserCollectibleGETFunctions
import database.CRUD.GET.Distribution.get_Distribution_CRUD_functions as DistributionGETFunctions
import database.CRUD.GET.DistributionCode.get_DistributionCode_CRUD_functions as DistributionCodeGETFunctions
import database.CRUD.GET.DistributionCodeUser.get_DistributionCodeUser_CRUD_functions as DistributionCodeUserGETFunctions
import database.CRUD.GET.DistributionCollectible.get_DistributionCollectible_CRUD_functions as DistributionCollectibleGETFunctions



API_PATHS_GET = {
    User_table: {
        "getUserByUserId": {
            "path": "/getUserByUserId",
            "active": True,
            "handler": UserGETFunctions.getUserByUserId,
            "response_model": UserResponse
        },
        "getUserByEmail": {
            "path": "/getUserByEmail",
            "active": True,
            "handler": UserGETFunctions.getUserByEmail,
            "response_model": UserResponse
        },
        "getUserByUsername": {
            "path": "/getUserByUsername",
            "active": True,
            "handler": UserGETFunctions.getUserByUsername,
            "response_model": UserResponse
        },
        "getUsersByLastLoggedIn": {
            "path": "/getUsersByLastLoggedIn",
            "active": True,
            "handler": UserGETFunctions.getUsersByLastLoggedIn,
            "response_model": List[UserResponse]
        }
    },

    Category_table: {
        "getCategoryByCategoryId": {
            "path": "/getCategoryByCategoryId",
            "active": True,
            "handler": CategoryGETFunctions.getCategoryByCategoryId,
            "response_model": CategoryResponse
        }
        # Note: No other GET functions listed for Category
    },

    Collection_table: {
        "getCollectionByCollectionId": {
            "path": "/getCollectionByCollectionId",
            "active": True,
            "handler": CollectionGETFunctions.getCollectionByCollectionId,
            "response_model": CollectionResponse
        },
        "getCollectionByName": {
            "path": "/getCollectionByName",
            "active": True,
            "handler": CollectionGETFunctions.getCollectionByName,
            "response_model": List[CollectionResponse]
        }
    },

    Collectible_table: {
        "getCollectibleByCollectibleId": {
            "path": "/getCollectibleByCollectibleId",
            "active": True,
            "handler": CollectibleGETFunctions.getCollectibleByCollectibleId,
            "response_model": CollectibleResponse
        },
        "getCollectibleByName": {
            "path": "/getCollectibleByName",
            "active": True,
            "handler": CollectibleGETFunctions.getCollectibleByName,
            "response_model": List[CollectibleResponse]
        },
        "getCollectiblesByLabel": {
            "path": "/getCollectiblesByLabel",
            "active": True,
            "handler": CollectibleGETFunctions.getCollectiblesByLabel,
            "response_model": List[CollectibleResponse]
        },
        "getCollectiblesBySponsor": {
            "path": "/getCollectiblesBySponsor",
            "active": True,
            "handler": CollectibleGETFunctions.getCollectiblesBySponsor,
            "response_model": List[CollectibleResponse]
        },
        "getCollectiblesByCollection": {
            "path": "/getCollectiblesByCollection",
            "active": True,
            "handler": CollectibleGETFunctions.getCollectiblesByCollection,
            "response_model": List[CollectibleResponse]
        },
        "getCollectiblesByCommunity": {
            "path": "/getCollectiblesByCommunity",
            "active": True,
            "handler": CollectibleGETFunctions.getCollectiblesByCommunity,
            "response_model": List[CollectibleResponse]
        },
        "getAllCollectibles": {
            "path": "/getAllCollectibles",
            "active": True,
            "handler": CollectibleGETFunctions.getAllCollectibles,
            "response_model": List[CollectibleResponse]
        },
        "getCollectiblesByProjectId": {
            "path": "/getCollectiblesByProjectId",
            "active": True,
            "handler": CollectibleGETFunctions.getCollectiblesByProjectId,
            "response_model": List[CollectibleResponse]
        },
        "getCollectiblesByCategoryId": {
            "path": "/getCollectiblesByCategoryId",
            "active": True,
            "handler": CollectibleGETFunctions.getCollectiblesByCategoryId,
            "response_model": List[CollectibleResponse]
        }
    },

    UserCollectible_table: {
        "getUserCollectibleByCollectibleIdAndMint": {
            "path": "/getUserCollectibleByCollectibleIdAndMint",
            "active": True,
            "handler": UserCollectibleGETFunctions.getUserCollectibleByCollectibleIdAndMint,
            "response_model": UserCollectibleResponse
        },
        "getUserCollectiblesByOwnerId": {
            "path": "/getUserCollectiblesByOwnerId",
            "active": True,
            "handler": UserCollectibleGETFunctions.getUserCollectiblesByOwnerId,
            "response_model": List[UserCollectibleResponse]
        },
        "getUserCollectiblesByLastOwned": {
            "path": "/getUserCollectiblesByLastOwned",
            "active": True,
            "handler": UserCollectibleGETFunctions.getUserCollectiblesByLastOwned,
            "response_model": List[UserCollectibleResponse]
        },
         "getUserCollectiblesByCollectibleId": {
            "path": "/getUserCollectiblesByCollectibleId",
            "active": True,
            "handler": UserCollectibleGETFunctions.getUserCollectiblesByCollectibleId,
            "response_model": List[UserCollectibleResponse]
        },
        "getUserCollectibleByUserCollectibleId": {
            "path": "/getUserCollectibleByUserCollectibleId",
            "active": True,
            "handler": UserCollectibleGETFunctions.getUserCollectibleByUserCollectibleId,
            "response_model": UserCollectibleResponse
        }
    },

    Community_table: {
        "getCommunityByCommunityId": {
            "path": "/getCommunityByCommunityId",
            "active": True,
            "handler": CommunityGETFunctions.getCommunityByCommunityId,
            "response_model": CommunityResponse
        },
        "getCommunityByTitle": {
            "path": "/getCommunityByTitle",
            "active": True,
            "handler": CommunityGETFunctions.getCommunityByTitle,
            "response_model": List[CommunityResponse]
        }
    },

    CommunityUser_table: {
        "getCommunityUsersByUserId": {
            "path": "/getCommunityUsersByUserId",
            "active": True,
            "handler": CommunityUserGETFunctions.getCommunityUsersByUserId,
            "response_model": List[CommunityUserResponse]
        },
        "getCommunityUsersByCommunityId": {
            "path": "/getCommunityUsersByCommunityId",
            "active": True,
            "handler": CommunityUserGETFunctions.getCommunityUsersByCommunityId,
            "response_model": List[CommunityUserResponse]
        }
    },

    Sponsor_table: {
        "getSponsorBySponsorId": {
            "path": "/getSponsorBySponsorId",
            "active": True,
            "handler": SponsorGETFunctions.getSponsorBySponsorId,
            "response_model": SponsorResponse
        },
        "getSponsorByName": {
            "path": "/getSponsorByName",
            "active": True,
            "handler": SponsorGETFunctions.getSponsorByName,
            "response_model": List[SponsorResponse]
        },
        "getSponsorByOrganization": {
            "path": "/getSponsorByOrganization",
            "active": True,
            "handler": SponsorGETFunctions.getSponsorByOrganization,
            "response_model": List[SponsorResponse]
        }
    },

    Notification_table: {
        "getNotificationByNotificationId": {
            "path": "/getNotificationByNotificationId",
            "active": True,
            "handler": NotificationGETFunctions.getNotificationByNotificationId,
            "response_model": NotificationResponse
        },
        "getNotificationsByDate": {
            "path": "/getNotificationsByDate",
            "active": True,
            "handler": NotificationGETFunctions.getNotificationsByDate,
            "response_model": List[NotificationResponse]
        },
        "getNotificationsByHeader": {
            "path": "/getNotificationsByHeader",
            "active": True,
            "handler": NotificationGETFunctions.getNotificationsByHeader,
            "response_model": List[NotificationResponse]
        }
    },

    NotificationUser_table: {
        "getNotificationUsersByUserId": {
            "path": "/getNotificationUsersByUserId",
            "active": True,
            "handler": NotificationUserGETFunctions.getNotificationUsersByUserId,
            "response_model": List[NotificationUserResponse]
        },
        "getNotificationUsersByNotificationId": {
            "path": "/getNotificationUsersByNotificationId",
            "active": True,
            "handler": NotificationUserGETFunctions.getNotificationUsersByNotificationId,
            "response_model": List[NotificationUserResponse]
        },
        "getNotificationUsersByUserIdAndDate": {
            "path": "/getNotificationUsersByUserIdAndDate",
            "active": True,
            "handler": NotificationUserGETFunctions.getNotificationUsersByUserIdAndDate,
            "response_model": List[NotificationUserResponse]
        }
    },

    NewsPost_table: {
        "getNewsPostByNewsPostId": {
            "path": "/getNewsPostByNewsPostId",
            "active": True,
            "handler": NewsPostGETFunctions.getNewsPostByNewsPostId,
            "response_model": NewsPostResponse
        },
        "getNewsPostsByDate": {
            "path": "/getNewsPostsByDate",
            "active": True,
            "handler": NewsPostGETFunctions.getNewsPostsByDate,
            "response_model": List[NewsPostResponse]
        },
        "getNewsPostsByHeader": {
            "path": "/getNewsPostsByHeader",
            "active": True,
            "handler": NewsPostGETFunctions.getNewsPostsByHeader,
            "response_model": List[NewsPostResponse]
        }
    },

    Mission_table: {
        "getMissionByMissionId": {
            "path": "/getMissionByMissionId",
            "active": True,
            "handler": MissionGETFunctions.getMissionByMissionId,
            "response_model": MissionResponse
        },
        "getMissionByTitle": {
            "path": "/getMissionByTitle",
            "active": True,
            "handler": MissionGETFunctions.getMissionByTitle,
            "response_model": List[MissionResponse]
        }
    },

    MissionUser_table: {
        "getMissionUsersByUserId": {
            "path": "/getMissionUsersByUserId",
            "active": True,
            "handler": MissionUserGETFunctions.getMissionUsersByUserId,
            "response_model": List[MissionUserResponse]
        },
        "getMissionUsersByChallengeId": { # Corresponds to MissionId in models
            "path": "/getMissionUsersByMissionId",
            "active": True,
            "handler": MissionUserGETFunctions.getMissionUsersByChallengeId, # Function name from CRUD file
            "response_model": List[MissionUserResponse]
        },
        "getMissionUsersByCompleted": {
            "path": "/getMissionUsersByCompleted",
            "active": True,
            "handler": MissionUserGETFunctions.getMissionUsersByCompleted,
            "response_model": List[MissionUserResponse]
        }
    },

    MissionUserData_table: {
        "getMissionUserDatasByChallengeUserId": { # Corresponds to MissionUserId in models
            "path": "/getMissionUserDatasByMissionUserId",
            "active": True,
            "handler": MissionUserDataGETFunctions.getMissionUserDatasByChallengeUserId, # Function name from CRUD file
            "response_model": List[MissionUserDataResponse]
        },
        "getMissionUserDatasByUserId": {
            "path": "/getMissionUserDatasByUserId",
            "active": True,
            "handler": MissionUserDataGETFunctions.getMissionUserDatasByUserId,
            "response_model": List[MissionUserDataResponse]
        },
        "getMissionUserDatasByChallengeId": { # Corresponds to MissionId in models (requires join)
            "path": "/getMissionUserDatasByMissionId",
            "active": True,
            "handler": MissionUserDataGETFunctions.getMissionUserDatasByChallengeId, # Function name from CRUD file
            "response_model": List[MissionUserDataResponse]
        }
    },

    CommunityChallenge_table: {
        "getCommunityChallengeByCommunityChallengeId": {
            "path": "/getCommunityChallengeByCommunityChallengeId",
            "active": True,
            "handler": CommunityChallengeGETFunctions.getCommunityChallengeByCommunityChallengeId,
            "response_model": CommunityChallengeResponse
        },
        "getCommunityChallengeByTitle": {
            "path": "/getCommunityChallengeByTitle",
            "active": True,
            "handler": CommunityChallengeGETFunctions.getCommunityChallengeByTitle,
            "response_model": List[CommunityChallengeResponse]
        }
    },

    Project_table: {
        "getProjectByProjectId": {
            "path": "/getProjectByProjectId",
            "active": True,
            "handler": ProjectGETFunctions.getProjectByProjectId,
            "response_model": ProjectResponse
        },
        "getProjectByName": {
            "path": "/getProjectByName",
            "active": True,
            "handler": ProjectGETFunctions.getProjectByName,
            "response_model": List[ProjectResponse]
        }
    },

    CollectibleSponsor_table: {
        "getCollectibleSponsorByCollectibleSponsorId": {
            "path": "/getCollectibleSponsorByCollectibleSponsorId",
            "active": True,
            "handler": CollectibleSponsorGETFunctions.getCollectibleSponsorByCollectibleSponsorId,
            "response_model": CollectibleSponsorResponse
        },
        "getCollectibleSponsorByCollectibleId": {
            "path": "/getCollectibleSponsorByCollectibleId",
            "active": True,
            "handler": CollectibleSponsorGETFunctions.getCollectibleSponsorByCollectibleId,
            "response_model": List[CollectibleSponsorResponse]
        },
        "getCollectibleSponsorBySponsorId": {
            "path": "/getCollectibleSponsorBySponsorId",
            "active": True,
            "handler": CollectibleSponsorGETFunctions.getCollectibleSponsorBySponsorId,
            "response_model": List[CollectibleSponsorResponse]
        }
    },

    Distribution_table: {
        "getDistributionByDistributionId": {
            "path": "/getDistributionByDistributionId",
            "active": True,
            "handler": DistributionGETFunctions.getDistributionByDistributionId,
            "response_model": DistributionResponse
        },
        "getAllDistributions": {
            "path": "/getAllDistributions",
            "active": True,
            "handler": DistributionGETFunctions.getAllDistributions,
            "response_model": List[DistributionResponse]
        },
        "getDistributionsByProjectId": {
            "path": "/getDistributionsByProjectId",
            "active": True,
            "handler": DistributionGETFunctions.getDistributionsByProjectId,
            "response_model": List[DistributionResponse]
        }
    },
    DistributionCode_table: {
        "getDistributionCodeByDistributionCodeId": {
            "path": "/getDistributionCodeByDistributionCodeId",
            "active": True,
            "handler": DistributionCodeGETFunctions.getDistributionCodeByDistributionCodeId,
            "response_model": DistributionCodeResponse
        },
        "getAllDistributionCodes": {
            "path": "/getAllDistributionCodes",
            "active": True,
            "handler": DistributionCodeGETFunctions.getAllDistributionCodes,
            "response_model": List[DistributionCodeResponse]
        },
        "getDistributionCodesByDistributionId": {
            "path": "/getDistributionCodesByDistributionId",
            "active": True,
            "handler": DistributionCodeGETFunctions.getDistributionCodesByDistributionId,
            "response_model": List[DistributionCodeResponse]
        },
        "getDistributionCodeByCode": {
            "path": "/getDistributionCodeByCode",
            "active": True,
            "handler": DistributionCodeGETFunctions.getDistributionCodeByCode,
            "response_model": DistributionCodeResponse
        }
    },
    DistributionCodeUser_table: {
        "getDistributionCodeUserByDistributionCodeUserId": {
            "path": "/getDistributionCodeUserByDistributionCodeUserId",
            "active": True,
            "handler": DistributionCodeUserGETFunctions.getDistributionCodeUserByDistributionCodeUserId,
            "response_model": DistributionCodeUserResponse
        },
        "getAllDistributionCodeUsers": {
            "path": "/getAllDistributionCodeUsers",
            "active": True,
            "handler": DistributionCodeUserGETFunctions.getAllDistributionCodeUsers,
            "response_model": List[DistributionCodeUserResponse]
        },
        "getDistributionCodeUsersByUserId": {
            "path": "/getDistributionCodeUsersByUserId",
            "active": True,
            "handler": DistributionCodeUserGETFunctions.getDistributionCodeUsersByUserId,
            "response_model": List[DistributionCodeUserResponse]
        },
        "getDistributionCodeUsersByDistributionCodeId": {
            "path": "/getDistributionCodeUsersByDistributionCodeId",
            "active": True,
            "handler": DistributionCodeUserGETFunctions.getDistributionCodeUsersByDistributionCodeId,
            "response_model": List[DistributionCodeUserResponse]
        }
    },
    DistributionCollectible_table: {
        "getDistributionCollectibleByDistributionCollectibleId": {
            "path": "/getDistributionCollectibleByDistributionCollectibleId",
            "active": True,
            "handler": DistributionCollectibleGETFunctions.getDistributionCollectibleByDistributionCollectibleId,
            "response_model": DistributionCollectibleResponse
        },
        "getAllDistributionCollectibles": {
            "path": "/getAllDistributionCollectibles",
            "active": True,
            "handler": DistributionCollectibleGETFunctions.getAllDistributionCollectibles,
            "response_model": List[DistributionCollectibleResponse]
        },
        "getDistributionCollectiblesByCollectibleId": {
            "path": "/getDistributionCollectiblesByCollectibleId",
            "active": True,
            "handler": DistributionCollectibleGETFunctions.getDistributionCollectiblesByCollectibleId,
            "response_model": List[DistributionCollectibleResponse]
        },
        "getDistributionCollectiblesByDistributionId": {
            "path": "/getDistributionCollectiblesByDistributionId",
            "active": True,
            "handler": DistributionCollectibleGETFunctions.getDistributionCollectiblesByDistributionId,
            "response_model": List[DistributionCollectibleResponse]
        }
    }
}

# Keep old variables for temporary compatibility if needed, but they aren't used by the new FastAPI router
# Example: GET_RAW_PATH_getUserByUserId = '/getUserByUserId'
# ... define others if necessary for a transition phase
