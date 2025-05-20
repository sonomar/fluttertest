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


API_PATHS_POST = {
    User_table: {
        "createUser": {
            "path": "/createUser",
            "active": True,
            "handler": UserPOSTFunctions.create_user,
            "response_model": UserResponse
        }
    },
    Category_table: {
        "createCategory": {
            "path": "/createCategory",
            "active": True,
            "handler": CategoryPOSTFunctions.create_category,
            "response_model": CategoryResponse
        }
    },
    Collection_table: {
        "createCollection": {
            "path": "/createCollection",
            "active": True,
            "handler": CollectionPOSTFunctions.create_collection,
            "response_model": CollectionResponse
        }
    },
    Collectible_table: {
        "createCollectible": {
            "path": "/createCollectible",
            "active": True,
            "handler": CollectiblePOSTFunctions.create_collectible,
            "response_model": CollectibleResponse
        }
    },
    CollectibleSponsor_table: {
        "createCollectibleSponsor": {
            "path": "/createCollectibleSponsor",
            "active": True,
            "handler": CollectibleSponsorPOSTFunctions.create_collectible_sponsor,
            "response_model": CollectibleSponsorResponse
        }
    },
    Community_table: {
        "createCommunity": {
            "path": "/createCommunity",
            "active": True,
            "handler": CommunityPOSTFunctions.create_community,
            "response_model": CommunityResponse
        }
    },
    CommunityChallenge_table: {
        "createCommunityChallenge": {
            "path": "/createCommunityChallenge",
            "active": True,
            "handler": CommunityChallengePOSTFunctions.create_community_challenge,
            "response_model": CommunityChallengeResponse
        }
    },
    CommunityUser_table: {
        "createCommunityUser": {
            "path": "/createCommunityUser",
            "active": True,
            "handler": CommunityUserPOSTFunctions.create_community_user,
            "response_model": CommunityUserResponse
        }
    },
    Mission_table: {
        "createMission": {
            "path": "/createMission",
            "active": True,
            "handler": MissionPOSTFunctions.create_mission,
            "response_model": MissionResponse
        }
    },
    MissionUser_table: {
        "createMissionUser": {
            "path": "/createMissionUser",
            "active": True,
            "handler": MissionUserPOSTFunctions.create_mission_user,
            "response_model": MissionUserResponse
        }
    },
    MissionUserData_table: {
        "createMissionUserData": {
            "path": "/createMissionUserData",
            "active": True,
            "handler": MissionUserDataPOSTFunctions.create_mission_user_data,
            "response_model": MissionUserDataResponse
        }
    },
    NewsPost_table: {
        "createNewsPost": {
            "path": "/createNewsPost",
            "active": True,
            "handler": NewsPostPOSTFunctions.create_news_post,
            "response_model": NewsPostResponse
        }
    },
    Notification_table: {
        "createNotification": {
            "path": "/createNotification",
            "active": True,
            "handler": NotificationPOSTFunctions.create_notification,
            "response_model": NotificationResponse
        }
    },
    NotificationUser_table: {
        "createNotificationUser": {
            "path": "/createNotificationUser",
            "active": True,
            "handler": NotificationUserPOSTFunctions.create_notification_user,
            "response_model": NotificationUserResponse
        }
    },
    Project_table: {
        "createProject": {
            "path": "/createProject",
            "active": True,
            "handler": ProjectPOSTFunctions.create_project,
            "response_model": ProjectResponse
        }
    },
    Sponsor_table: {
        "createSponsor": {
            "path": "/createSponsor",
            "active": True,
            "handler": SponsorPOSTFunctions.create_sponsor,
            "response_model": SponsorResponse
        }
    },
    UserCollectible_table: {
        "createUserCollectible": {
            "path": "/createUserCollectible",
            "active": True,
            "handler": UserCollectiblePOSTFunctions.create_user_collectible,
            "response_model": UserCollectibleResponse
        }
    }
}