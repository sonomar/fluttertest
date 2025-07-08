# src/api/POST/api_path_post.py
from api.table import *
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
from database.schema.GET.MissionType.missionType_schema import MissionTypeResponse

# Import the modules containing your refactored POST handler functions
import database.CRUD.POST.User.post_User_CRUD_functions as UserPOSTFunctions
import database.CRUD.POST.Category.post_Category_CRUD_functions as CategoryPOSTFunctions
import database.CRUD.POST.Collection.post_Collection_CRUD_functions as CollectionPOSTFunctions
import database.CRUD.POST.Collectible.post_Collectible_CRUD_functions as CollectiblePOSTFunctions
import database.CRUD.POST.CollectibleSponsor.post_CollectibleSponsor_CRUD_functions as CollectibleSponsorPOSTFunctions
import database.CRUD.POST.Community.post_Community_CRUD_functions as CommunityPOSTFunctions
import database.CRUD.POST.CommunityChallenge.post_CommunityChallenge_CRUD_functions as CommunityChallengePOSTFunctions
import database.CRUD.POST.CommunityUser.post_CommunityUser_CRUD_functions as CommunityUserPOSTFunctions
import database.CRUD.POST.Mission.post_Mission_CRUD_functions as MissionPOSTFunctions
import database.CRUD.POST.MissionUser.post_MissionUser_CRUD_functions as MissionUserPOSTFunctions
import database.CRUD.POST.MissionUserData.post_MissionUserData_CRUD_functions as MissionUserDataPOSTFunctions
import database.CRUD.POST.NewsPost.post_NewsPost_CRUD_functions as NewsPostPOSTFunctions
import database.CRUD.POST.Notification.post_Notification_CRUD_functions as NotificationPOSTFunctions
import database.CRUD.POST.NotificationUser.post_NotificationUser_CRUD_functions as NotificationUserPOSTFunctions
import database.CRUD.POST.Project.post_Project_CRUD_functions as ProjectPOSTFunctions
import database.CRUD.POST.Sponsor.post_Sponsor_CRUD_functions as SponsorPOSTFunctions
import database.CRUD.POST.UserCollectible.post_UserCollectible_CRUD_functions as UserCollectiblePOSTFunctions
import database.CRUD.POST.Distribution.post_Distribution_CRUD_functions as DistributionPOSTFunctions
import database.CRUD.POST.DistributionCode.post_DistributionCode_CRUD_functions as DistributionCodePOSTFunctions
import database.CRUD.POST.DistributionCodeUser.post_DistributionCodeUser_CRUD_functions as DistributionCodeUserPOSTFunctions
import database.CRUD.POST.DistributionCollectible.post_DistributionCollectible_CRUD_functions as DistributionCollectiblePOSTFunctions
import database.CRUD.POST.MissionType.post_MissionType_CRUD_functions as MissionTypePOSTFunctions


API_PATHS_POST = {
    User_table: {
        "createUser": {
            "path": "/createUser",
            "active": True,
            "handler": UserPOSTFunctions.createUser,
            "response_model": UserResponse
        }
    },
    Category_table: {
        "createCategory": {
            "path": "/createCategory",
            "active": True,
            "handler": CategoryPOSTFunctions.createCategory,
            "response_model": CategoryResponse
        }
    },
    Collection_table: {
        "createCollection": {
            "path": "/createCollection",
            "active": True,
            "handler": CollectionPOSTFunctions.createCollection,
            "response_model": CollectionResponse
        }
    },
    Collectible_table: {
        "createCollectible": {
            "path": "/createCollectible",
            "active": True,
            "handler": CollectiblePOSTFunctions.createCollectible,
            "response_model": CollectibleResponse
        }
    },
    CollectibleSponsor_table: {
        "createCollectibleSponsor": {
            "path": "/createCollectibleSponsor",
            "active": True,
            "handler": CollectibleSponsorPOSTFunctions.createCollectibleSponsor,
            "response_model": CollectibleSponsorResponse
        }
    },
    Community_table: {
        "createCommunity": {
            "path": "/createCommunity",
            "active": True,
            "handler": CommunityPOSTFunctions.createCommunity,
            "response_model": CommunityResponse
        }
    },
    CommunityChallenge_table: {
        "createCommunityChallenge": {
            "path": "/createCommunityChallenge",
            "active": True,
            "handler": CommunityChallengePOSTFunctions.createCommunityChallenge,
            "response_model": CommunityChallengeResponse
        }
    },
    CommunityUser_table: {
        "createCommunityUser": {
            "path": "/createCommunityUser",
            "active": True,
            "handler": CommunityUserPOSTFunctions.createCommunityUser,
            "response_model": CommunityUserResponse
        }
    },
    Mission_table: {
        "createMission": {
            "path": "/createMission",
            "active": True,
            "handler": MissionPOSTFunctions.createMission,
            "response_model": MissionResponse
        }
    },
    MissionType_table: {
        "createMissionType": {
            "path": "/createMissionType",
            "active": True,
            "handler": MissionTypePOSTFunctions.createMissionType,
            "response_model": MissionTypeResponse
        }
    },
    MissionUser_table: {
        "createMissionUser": {
            "path": "/createMissionUser",
            "active": True,
            "handler": MissionUserPOSTFunctions.createMissionUser,
            "response_model": MissionUserResponse
        }
    },
    MissionUserData_table: {
        "createMissionUserData": {
            "path": "/createMissionUserData",
            "active": True,
            "handler": MissionUserDataPOSTFunctions.createMissionUserData,
            "response_model": MissionUserDataResponse
        }
    },
    NewsPost_table: {
        "createNewsPost": {
            "path": "/createNewsPost",
            "active": True,
            "handler": NewsPostPOSTFunctions.createNewsPost,
            "response_model": NewsPostResponse
        }
    },
    Notification_table: {
        "createNotification": {
            "path": "/createNotification",
            "active": True,
            "handler": NotificationPOSTFunctions.createNotification,
            "response_model": NotificationResponse
        }
    },
    NotificationUser_table: {
        "createNotificationUser": {
            "path": "/createNotificationUser",
            "active": True,
            "handler": NotificationUserPOSTFunctions.createNotificationUser,
            "response_model": NotificationUserResponse
        }
    },
    Project_table: {
        "createProject": {
            "path": "/createProject",
            "active": True,
            "handler": ProjectPOSTFunctions.createProject,
            "response_model": ProjectResponse
        }
    },
    Sponsor_table: {
        "createSponsor": {
            "path": "/createSponsor",
            "active": True,
            "handler": SponsorPOSTFunctions.createSponsor,
            "response_model": SponsorResponse
        }
    },
    UserCollectible_table: {
        "createUserCollectible": {
            "path": "/createUserCollectible",
            "active": True,
            "handler": UserCollectiblePOSTFunctions.createUserCollectible,
            "response_model": UserCollectibleResponse
        }
    },
    "Distribution": {
        "createDistribution": {
            "path": "/createDistribution",
            "active": True,
            "handler": DistributionPOSTFunctions.createDistribution,
            "response_model": DistributionResponse
        }
    },
    "DistributionCode": {
        "createDistributionCode": {
            "path": "/createDistributionCode",
            "active": True,
            "handler": DistributionCodePOSTFunctions.createDistributionCode,
            "response_model": DistributionCodeResponse
        }
    },
    "DistributionCodeUser": {
        "createDistributionCodeUser": {
            "path": "/createDistributionCodeUser",
            "active": True,
            "handler": DistributionCodeUserPOSTFunctions.createDistributionCodeUser,
            "response_model": DistributionCodeUserResponse
        }
    },
    "DistributionCollectible": {
        "createDistributionCollectible": {
            "path": "/createDistributionCollectible",
            "active": True,
            "handler": DistributionCollectiblePOSTFunctions.createDistributionCollectible,
            "response_model": DistributionCollectibleResponse
        }
    }
}