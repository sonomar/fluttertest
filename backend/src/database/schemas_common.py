# src/schemas.py
from pydantic import BaseModel, EmailStr, Field
from typing import Optional, Dict, Any, List
import datetime

# --- User Schemas ---

# Base schema for common fields
class UserBase(BaseModel):
    email: EmailStr
    username: Optional[str] = None
    profileImg: Optional[str] = None
    deviceId: Optional[str] = None
    # userType will be handled via UserCreate/UserUpdate if needed as input
    # For output, it will be in UserResponse


# --- Category Schemas ---
class CategoryBase(BaseModel):
    name: str

class CategoryCreate(CategoryBase):
    pass

class CategoryResponse(CategoryBase):
    categoryId: int
    createdDt: datetime.datetime
    updatedDt: datetime.datetime

    class Config:
        orm_mode = True

# --- Community Schemas ---
class CommunityBase(BaseModel):
    title: str
    description: Optional[str] = None
    imageRef: Optional[Dict[str, Any]] = None
    vidRef: Optional[Dict[str, Any]] = None
    qrRef: Optional[Dict[str, Any]] = None
    embedRef: Optional[Dict[str, Any]] = None
    active: Optional[bool] = True

class CommunityCreate(CommunityBase):
    pass

class CommunityResponse(CommunityBase):
    communityId: int
    createdDt: datetime.datetime
    updatedDt: datetime.datetime

    class Config:
        orm_mode = True

# --- Collection Schemas ---
class CollectionBase(BaseModel):
    communityId: int # Assuming you pass the communityId when creating/updating a collection
    name: str
    description: Optional[str] = None
    imageRef: Optional[Dict[str, Any]] = None
    vidRef: Optional[Dict[str, Any]] = None
    qrRef: Optional[Dict[str, Any]] = None
    embedRef: Optional[Dict[str, Any]] = None
    active: Optional[bool] = True

class CollectionCreate(CollectionBase):
    pass

class CollectionResponse(CollectionBase):
    collectionId: int
    createdDt: datetime.datetime
    updatedDt: datetime.datetime

    class Config:
        orm_mode = True

# --- Project Schemas ---
class ProjectBase(BaseModel):
    name: str
    attributed: Dict[str, Any] # Assuming attributed is always a dict
    location: Optional[str] = None
    active: Optional[bool] = True

class ProjectCreate(ProjectBase):
    pass

class ProjectResponse(ProjectBase):
    projectId: int
    createdDt: datetime.datetime
    updatedDt: datetime.datetime

    class Config:
        orm_mode = True

# --- Collectible Schemas ---
class CollectibleBase(BaseModel):
    collectionId: int
    categoryId: int
    projectId: int
    communityId: int
    label: str
    name: str
    description: Optional[str] = None
    imageRef: Optional[Dict[str, Any]] = None
    vidRef: Optional[Dict[str, Any]] = None
    qrRef: Optional[Dict[str, Any]] = None
    embedRef: Optional[Dict[str, Any]] = None
    circulation: Optional[int] = None
    publicationDate: Optional[datetime.datetime] = None
    active: Optional[bool] = True

class CollectibleCreate(CollectibleBase):
    pass

class CollectibleUpdate(CollectibleBase):
     # Inherit base fields and make them optional for updates
     collectionId: Optional[int] = None
     categoryId: Optional[int] = None
     projectId: Optional[int] = None
     communityId: Optional[int] = None
     label: Optional[str] = None
     name: Optional[str] = None
     description: Optional[str] = None
     imageRef: Optional[Dict[str, Any]] = None
     vidRef: Optional[Dict[str, Any]] = None
     qrRef: Optional[Dict[str, Any]] = None
     embedRef: Optional[Dict[str, Any]] = None
     circulation: Optional[int] = None
     publicationDate: Optional[datetime.datetime] = None
     active: Optional[bool] = None

class CollectibleResponse(CollectibleBase):
    collectibleId: int
    createdDt: datetime.datetime
    updatedDt: datetime.datetime

    class Config:
        orm_mode = True

# --- UserCollectible Schemas ---
class UserCollectibleBase(BaseModel):
    ownerId: int
    collectibleId: int
    mint: int # Mint number is part of the unique key
    previousOwnerId: Optional[int] = None
    lastTransferredDt: Optional[datetime.datetime] = None
    active: Optional[bool] = True
    favorite: Optional[bool] = False

class UserCollectibleCreate(UserCollectibleBase):
     pass # Mint number is required for creation

class UserCollectibleResponse(UserCollectibleBase):
    userCollectibleId: int
    createdDt: datetime.datetime
    updatedDt: datetime.datetime

    class Config:
        orm_mode = True

# --- CommunityUser Schemas ---
class CommunityUserBase(BaseModel):
    communityId: int
    memberId: int

class CommunityUserCreate(CommunityUserBase):
    pass

class CommunityUserResponse(CommunityUserBase):
    communityUserId: int
    createdDt: datetime.datetime
    updatedDt: datetime.datetime

    class Config:
        orm_mode = True

# --- Sponsor Schemas ---
class SponsorBase(BaseModel):
    name: str
    organization: Optional[str] = None
    urls: Optional[Dict[str, Any]] = None
    description: Optional[str] = None
    imageRef: Optional[Dict[str, Any]] = None
    vidRef: Optional[Dict[str, Any]] = None
    qrRef: Optional[Dict[str, Any]] = None
    embedRef: Optional[Dict[str, Any]] = None
    sponsorCity: Optional[str] = None
    sponsorCountry: Optional[str] = None
    sponsorZip: Optional[str] = None
    primaryContactName: Optional[str] = None
    primaryContactEmail: Optional[EmailStr] = None
    primaryContactPhone: Optional[int] = None # Using int for BIGINT
    active: Optional[bool] = True

class SponsorCreate(SponsorBase):
    pass

class SponsorResponse(SponsorBase):
    sponsorId: int
    createdDt: datetime.datetime
    updatedDt: datetime.datetime

    class Config:
        orm_mode = True


# --- CollectibleSponsor Schemas ---
class CollectibleSponsorBase(BaseModel):
    collectibleId: int
    sponsorId: int
    sponsorMessage: Optional[str] = None
    active: Optional[bool] = True

class CollectibleSponsorCreate(CollectibleSponsorBase):
    pass

class CollectibleSponsorResponse(CollectibleSponsorBase):
    collectibleSponsorId: int
    
    class Config:
        orm_mode = True

# --- Notification Schemas ---
class NotificationBase(BaseModel):
    header: str
    content: str
    link: Optional[Dict[str, Any]] = None
    pushNotification: Optional[bool] = False
    private: Optional[bool] = False
    imgRef: Optional[Dict[str, Any]] = None
    vidRef: Optional[Dict[str, Any]] = None
    qrRef: Optional[Dict[str, Any]] = None
    embedRef: Optional[Dict[str, Any]] = None
    active: Optional[bool] = True

class NotificationCreate(NotificationBase):
    pass

class NotificationResponse(NotificationBase):
    notificationId: int
    createdDt: datetime.datetime
    updatedDt: datetime.datetime

    class Config:
        orm_mode = True

# --- NotificationUser Schemas ---
class NotificationUserBase(BaseModel):
    notificationId: int
    userId: int
    markRead: Optional[bool] = False
    archived: Optional[bool] = False
    deleted: Optional[bool] = False
    pushNotification: Optional[bool] = False # This seems duplicated, check DB schema

class NotificationUserCreate(NotificationUserBase):
    pass

class NotificationUserResponse(NotificationUserBase):
    notificationUserId: int
    createdDt: datetime.datetime
    updatedDt: datetime.datetime

    class Config:
        orm_mode = True

# --- NewsPost Schemas ---
class NewsPostBase(BaseModel):
    header: str
    body: str
    shortBody: str
    postDate: Optional[datetime.datetime] = Field(default_factory=datetime.datetime.utcnow) # Use utcnow as default
    type: Optional[str] = None
    imgRef: Optional[Dict[str, Any]] = None
    vidRef: Optional[Dict[str, Any]] = None
    qrRef: Optional[Dict[str, Any]] = None
    embedRef: Optional[Dict[str, Any]] = None
    active: Optional[bool] = True

class NewsPostCreate(NewsPostBase):
    pass

class NewsPostResponse(NewsPostBase):
    newsPostId: int
    createdDt: datetime.datetime
    updatedDt: datetime.datetime

    class Config:
        orm_mode = True

# --- Mission Schemas ---
class MissionBase(BaseModel):
    collectionId: int
    title: str
    description: Optional[str] = None
    reward: Optional[str] = None
    goal: int
    timer: Optional[bool] = False
    endDate: Optional[datetime.datetime] = None
    imgRef: Optional[Dict[str, Any]] = None
    vidRef: Optional[Dict[str, Any]] = None
    qrRef: Optional[Dict[str, Any]] = None
    embedRef: Optional[Dict[str, Any]] = None

class MissionCreate(MissionBase):
    pass

class MissionResponse(MissionBase):
    missionId: int
    createdDt: datetime.datetime
    updatedDt: datetime.datetime

    class Config:
        orm_mode = True

# --- MissionUser Schemas ---
class MissionUserBase(BaseModel):
    userId: int
    missionId: int
    progress: Optional[int] = 0
    status: Optional[str] = None
    completed: Optional[bool] = False
    dateCompleted: Optional[datetime.datetime] = None
    rewardClaimed: Optional[bool] = False

class MissionUserCreate(MissionUserBase):
    pass

class MissionUserResponse(MissionUserBase):
    missionUserId: int
    createdDt: datetime.datetime
    updatedDt: datetime.datetime

    class Config:
        orm_mode = True

# --- MissionUserData Schemas ---
class MissionUserDataBase(BaseModel):
    missionUserId: int
    action: Optional[str] = None
    status: Optional[str] = None

class MissionUserDataCreate(MissionUserDataBase):
     pass

class MissionUserDataResponse(MissionUserDataBase):
    missionUserDataId: int
    createdDt: datetime.datetime

    class Config:
        orm_mode = True

# --- CollectibleSponsor Schemas --- (Re-defined as it was out of order)
# Assuming this is a join table with potentially extra data
class CollectibleSponsorBase(BaseModel):
    collectibleId: int
    sponsorId: int
    sponsorMessage: Optional[str] = None
    active: Optional[bool] = True

class CollectibleSponsorCreate(CollectibleSponsorBase):
    pass

class CollectibleSponsorResponse(CollectibleSponsorBase):
    collectibleSponsorId: int

    class Config:
        orm_mode = True