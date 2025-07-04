# models.py
from typing import List, Optional


from sqlalchemy import BigInteger, Enum, ForeignKeyConstraint, Index, JSON, String, TIMESTAMP, Text, text, Boolean, Integer
from sqlalchemy.dialects.mysql import BIGINT, INTEGER, TINYINT
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, relationship
import datetime

# # The Base class is now imported from src.database, remove its definition here
class Base(DeclarativeBase): # <-- REMOVED
     pass # <-- REMOVED

# Define Python Enum for userType if using Enum type hint
import enum
class UserTypeEnum(enum.Enum): # <-- ADDED
    unregistered = "unregistered"
    username = "username"
    email = "email"
    admin = "admin"
    onboarding = "onboarding"

class DistributionTypeEnum(enum.Enum):
    voucher = "voucher"
    coupon = "coupon"
    deal = "deal"
    scan = "scan"

class Category(Base):
    __tablename__ = 'Category'
    __table_args__ = (
        Index('categoryId', 'categoryId', unique=True),
    )

    categoryId: Mapped[int] = mapped_column(BIGINT, primary_key=True)
    name: Mapped[str] = mapped_column(String(255))
    createdDt: Mapped[datetime.datetime] = mapped_column(TIMESTAMP, server_default=text('CURRENT_TIMESTAMP'))
    updatedDt: Mapped[datetime.datetime] = mapped_column(TIMESTAMP, server_default=text('CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP'))

    Collectible: Mapped[List['Collectible']] = relationship('Collectible', back_populates='Category_')


class Community(Base):
    __tablename__ = 'Community'
    __table_args__ = (
        Index('communityId', 'communityId', unique=True),
    )

    communityId: Mapped[int] = mapped_column(BIGINT, primary_key=True)
    title: Mapped[dict[str, str]] = mapped_column(JSON)
    createdDt: Mapped[datetime.datetime] = mapped_column(TIMESTAMP, server_default=text('CURRENT_TIMESTAMP'))
    updatedDt: Mapped[datetime.datetime] = mapped_column(TIMESTAMP, server_default=text('CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP'))
    active: Mapped[bool] = mapped_column(Boolean, server_default=text("'1'"))
    description: Mapped[Optional[dict[str, str]]] = mapped_column(JSON)
    imageRef: Mapped[Optional[dict]] = mapped_column(JSON)
    vidRef: Mapped[Optional[dict]] = mapped_column(JSON)
    qrRef: Mapped[Optional[dict]] = mapped_column(JSON)
    embedRef: Mapped[Optional[dict]] = mapped_column(JSON)

    Collection: Mapped[List['Collection']] = relationship('Collection', back_populates='Community_')
    CommunityChallenge: Mapped[List['CommunityChallenge']] = relationship('CommunityChallenge', back_populates='Community_')
    CommunityUser: Mapped[List['CommunityUser']] = relationship('CommunityUser', back_populates='Community_')
    Collectible: Mapped[List['Collectible']] = relationship('Collectible', back_populates='Community_')


class NewsPost(Base):
    __tablename__ = 'NewsPost'
    __table_args__ = (
        Index('newsPostId', 'newsPostId', unique=True),
    )

    newsPostId: Mapped[int] = mapped_column(BIGINT, primary_key=True)
    header: Mapped[dict[str, str]] = mapped_column(JSON)
    body: Mapped[dict[str, str]] = mapped_column(JSON)
    shortBody: Mapped[dict[str, str]] = mapped_column(JSON)
    postDate: Mapped[datetime.datetime] = mapped_column(TIMESTAMP, server_default=text('CURRENT_TIMESTAMP'))
    createdDt: Mapped[datetime.datetime] = mapped_column(TIMESTAMP, server_default=text('CURRENT_TIMESTAMP'))
    updatedDt: Mapped[datetime.datetime] = mapped_column(TIMESTAMP, server_default=text('CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP'))
    active: Mapped[bool] = mapped_column(Boolean, server_default=text("'1'"))
    type: Mapped[Optional[str]] = mapped_column(String(255))
    imgRef: Mapped[Optional[dict]] = mapped_column(JSON)
    vidRef: Mapped[Optional[dict]] = mapped_column(JSON)
    qrRef: Mapped[Optional[dict]] = mapped_column(JSON)
    embedRef: Mapped[Optional[dict]] = mapped_column(JSON)


class Notification(Base):
    __tablename__ = 'Notification'
    __table_args__ = (
        Index('notificationId', 'notificationId', unique=True),
    )

    notificationId: Mapped[int] = mapped_column(BIGINT, primary_key=True)
    header: Mapped[dict[str, str]] = mapped_column(JSON)
    content: Mapped[dict[str, str]] = mapped_column(JSON)
    pushNotification: Mapped[bool] = mapped_column(Boolean, server_default=text("'0'"))
    private: Mapped[bool] = mapped_column(Boolean, server_default=text("'0'"))
    createdDt: Mapped[datetime.datetime] = mapped_column(TIMESTAMP, server_default=text('CURRENT_TIMESTAMP'))
    updatedDt: Mapped[datetime.datetime] = mapped_column(TIMESTAMP, server_default=text('CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP'))
    active: Mapped[bool] = mapped_column(Boolean, server_default=text("'1'"))
    link: Mapped[Optional[dict]] = mapped_column(JSON)
    imgRef: Mapped[Optional[dict]] = mapped_column(JSON)
    vidRef: Mapped[Optional[dict]] = mapped_column(JSON)
    qrRef: Mapped[Optional[dict]] = mapped_column(JSON)
    embedRef: Mapped[Optional[dict]] = mapped_column(JSON)

    NotificationUser: Mapped[List['NotificationUser']] = relationship('NotificationUser', back_populates='Notification_')


class Project(Base):
    __tablename__ = 'Project'
    __table_args__ = (
        Index('projectId', 'projectId', unique=True),
    )

    projectId: Mapped[int] = mapped_column(BIGINT, primary_key=True)
    name: Mapped[dict[str, str]] = mapped_column(JSON)
    attributed: Mapped[dict] = mapped_column(JSON)
    createdDt: Mapped[datetime.datetime] = mapped_column(TIMESTAMP, server_default=text('CURRENT_TIMESTAMP'))
    updatedDt: Mapped[datetime.datetime] = mapped_column(TIMESTAMP, server_default=text('CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP'))
    active: Mapped[bool] = mapped_column(Boolean, server_default=text("'1'"))
    location: Mapped[Optional[str]] = mapped_column(String(255))

    Collectible: Mapped[List['Collectible']] = relationship('Collectible', back_populates='Project_')
    Collection: Mapped[List['Collection']] = relationship('Collection', back_populates='Project_')
    Distribution: Mapped[List['Distribution']] = relationship('Distribution', back_populates='Project_')


class Sponsor(Base):
    __tablename__ = 'Sponsor'
    __table_args__ = (
        Index('sponsorId', 'sponsorId', unique=True),
    )

    sponsorId: Mapped[int] = mapped_column(BIGINT, primary_key=True)
    name: Mapped[dict[str, str]] = mapped_column(JSON)
    createdDt: Mapped[datetime.datetime] = mapped_column(TIMESTAMP, server_default=text('CURRENT_TIMESTAMP'))
    updatedDt: Mapped[datetime.datetime] = mapped_column(TIMESTAMP, server_default=text('CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP'))
    active: Mapped[bool] = mapped_column(Boolean, server_default=text("'1'"))
    organization: Mapped[Optional[dict[str, str]]] = mapped_column(JSON)
    urls: Mapped[Optional[dict]] = mapped_column(JSON)
    description: Mapped[Optional[dict[str, str]]] = mapped_column(JSON)
    imageRef: Mapped[Optional[dict]] = mapped_column(JSON)
    vidRef: Mapped[Optional[dict]] = mapped_column(JSON)
    qrRef: Mapped[Optional[dict]] = mapped_column(JSON)
    embedRef: Mapped[Optional[dict]] = mapped_column(JSON)
    sponsorCity: Mapped[Optional[str]] = mapped_column(String(255))
    sponsorCountry: Mapped[Optional[str]] = mapped_column(String(255))
    sponsorZip: Mapped[Optional[str]] = mapped_column(String(20))
    primaryContactName: Mapped[Optional[str]] = mapped_column(String(255))
    primaryContactEmail: Mapped[Optional[str]] = mapped_column(String(255))
    primaryContactPhone: Mapped[Optional[int]] = mapped_column(BigInteger)
    
    CollectibleSponsor: Mapped[List['CollectibleSponsor']] = relationship('CollectibleSponsor', back_populates='Sponsor_')


class User(Base):
    __tablename__ = 'User'
    __table_args__ = (
        Index('email', 'email', unique=True),
        Index('userId', 'userId', unique=True),
        Index('username', 'username', unique=True)
    )

    userId: Mapped[int] = mapped_column(BIGINT, primary_key=True)
    active: Mapped[bool] = mapped_column(Boolean, server_default=text("'1'"))
    email: Mapped[str] = mapped_column(String(255))
    passwordHashed: Mapped[str] = mapped_column(String(255))
    createdDt: Mapped[datetime.datetime] = mapped_column(TIMESTAMP, server_default=text('CURRENT_TIMESTAMP'))
    updatedDt: Mapped[datetime.datetime] = mapped_column(TIMESTAMP, server_default=text('CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP'))
    userRank: Mapped[Optional[dict]] = mapped_column(JSON)
    username: Mapped[Optional[str]] = mapped_column(String(255))
    profileImg: Mapped[Optional[str]] = mapped_column(String(255))
    authToken: Mapped[Optional[str]] = mapped_column(Text)
    deviceId: Mapped[Optional[str]] = mapped_column(String(255))
    userType: Mapped[Optional['UserTypeEnum']] = mapped_column(Enum('unregistered', 'username', 'email', 'admin', 'onboarding', name='userType'), server_default=text("'onboarding'"))
    lastLoggedIn: Mapped[Optional[datetime.datetime]] = mapped_column(TIMESTAMP)
    score: Mapped[Optional[int]] = mapped_column(Integer)
    cognitoUsername: Mapped[Optional[str]] = mapped_column(String(255))
    isOnBlockchain: Mapped[Optional[bool]] = mapped_column(Boolean)
    blockchainUserAddress: Mapped[Optional[str]] = mapped_column(String(255))
    pushToken: Mapped[Optional[str]] = mapped_column(String(255))
    authData: Mapped[Optional[dict]] = mapped_column(JSON)

    CommunityUser: Mapped[List['CommunityUser']] = relationship('CommunityUser', back_populates='User_')
    NotificationUser: Mapped[List['NotificationUser']] = relationship('NotificationUser', back_populates='User_')
    MissionUser: Mapped[List['MissionUser']] = relationship('MissionUser', back_populates='User_')
    UserCollectible: Mapped[List['UserCollectible']] = relationship('UserCollectible', foreign_keys='[UserCollectible.ownerId]', back_populates='User_')
    UserCollectible_: Mapped[List['UserCollectible']] = relationship('UserCollectible', foreign_keys='[UserCollectible.previousOwnerId]', back_populates='User1')
    DistributionCodeUser: Mapped[List['DistributionCodeUser']] = relationship('DistributionCodeUser', foreign_keys='[DistributionCodeUser.userId]', back_populates='User_')
    DistributionCodeUser_: Mapped[List['DistributionCodeUser']] = relationship('DistributionCodeUser', foreign_keys='[DistributionCodeUser.previousOwnerId]', back_populates='User1')


class Collection(Base):
    __tablename__ = 'Collection'
    __table_args__ = (
        ForeignKeyConstraint(['communityId'], ['Community.communityId'], ondelete='CASCADE', onupdate='CASCADE', name='collection_ibfk_1'),
        ForeignKeyConstraint(['projectId'], ['Project.projectId'], ondelete='CASCADE', onupdate='CASCADE', name='collection_ibfk_2'),
        Index('collectionId', 'collectionId', unique=True),
        Index('communityId', 'communityId'),
        Index('projectId', 'projectId')
    )

    collectionId: Mapped[int] = mapped_column(BIGINT, primary_key=True)
    communityId: Mapped[int] = mapped_column(BIGINT)
    projectId: Mapped[int] = mapped_column(BIGINT)
    name: Mapped[dict[str, str]] = mapped_column(JSON)
    createdDt: Mapped[datetime.datetime] = mapped_column(TIMESTAMP, server_default=text('CURRENT_TIMESTAMP'))
    updatedDt: Mapped[datetime.datetime] = mapped_column(TIMESTAMP, server_default=text('CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP'))
    active: Mapped[bool] = mapped_column(Boolean, server_default=text("'1'"))
    description: Mapped[Optional[dict[str, str]]] = mapped_column(JSON)
    imageRef: Mapped[Optional[dict]] = mapped_column(JSON)
    vidRef: Mapped[Optional[dict]] = mapped_column(JSON)
    qrRef: Mapped[Optional[dict]] = mapped_column(JSON)
    embedRef: Mapped[Optional[dict]] = mapped_column(JSON)

    Community_: Mapped['Community'] = relationship('Community', back_populates='Collection')
    Project_: Mapped['Project'] = relationship('Project', back_populates='Collection')
    Collectible: Mapped[List['Collectible']] = relationship('Collectible', back_populates='Collection_')
    Mission: Mapped[List['Mission']] = relationship('Mission', back_populates='Collection_')
    Distribution: Mapped[List['Distribution']] = relationship('Distribution', back_populates='Collection_')


class CommunityChallenge(Base):
    __tablename__ = 'CommunityChallenge'
    __table_args__ = (
        ForeignKeyConstraint(['communityId'], ['Community.communityId'], ondelete='CASCADE', onupdate='CASCADE', name='communitychallenge_ibfk_1'),
        ForeignKeyConstraint(['rewardId'], ['Collectible.collectibleId'], ondelete='SET NULL', onupdate='CASCADE', name='communitychallenge_ibfk_2'),
        Index('communityChallengeId', 'communityChallengeId', unique=True),
        Index('communityId', 'communityId')
    )

    communityChallengeId: Mapped[int] = mapped_column(BIGINT, primary_key=True)
    communityId: Mapped[int] = mapped_column(BIGINT)
    title: Mapped[dict[str, str]] = mapped_column(JSON)
    goal: Mapped[int] = mapped_column(INTEGER)
    timer: Mapped[bool] = mapped_column(Boolean, server_default=text("'0'"))
    createdDt: Mapped[datetime.datetime] = mapped_column(TIMESTAMP, server_default=text('CURRENT_TIMESTAMP'))
    updatedDt: Mapped[datetime.datetime] = mapped_column(TIMESTAMP, server_default=text('CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP'))
    description: Mapped[Optional[dict[str, str]]] = mapped_column(JSON)
    reward: Mapped[Optional[dict]] = mapped_column(JSON)
    rewardId: Mapped[Optional[int]] = mapped_column(BIGINT)
    startDate: Mapped[Optional[datetime.datetime]] = mapped_column(TIMESTAMP)
    endDate: Mapped[Optional[datetime.datetime]] = mapped_column(TIMESTAMP)
    imgRef: Mapped[Optional[dict]] = mapped_column(JSON)
    vidRef: Mapped[Optional[dict]] = mapped_column(JSON)
    qrRef: Mapped[Optional[dict]] = mapped_column(JSON)
    webRef: Mapped[Optional[dict]] = mapped_column(JSON)
    embedRef: Mapped[Optional[str]] = mapped_column(String(255))

    Community_: Mapped['Community'] = relationship('Community', back_populates='CommunityChallenge')


class CommunityUser(Base):
    __tablename__ = 'CommunityUser'
    __table_args__ = (
        ForeignKeyConstraint(['communityId'], ['Community.communityId'], ondelete='CASCADE', onupdate='CASCADE', name='communityuser_ibfk_1'),
        ForeignKeyConstraint(['memberId'], ['User.userId'], ondelete='CASCADE', onupdate='CASCADE', name='communityuser_ibfk_2'),
        Index('communityUserId', 'communityUserId', unique=True),
        Index('memberId', 'memberId'),
        Index('unique_community_member', 'communityId', 'memberId', unique=True)
    )

    communityUserId: Mapped[int] = mapped_column(BIGINT, primary_key=True)
    communityId: Mapped[int] = mapped_column(BIGINT)
    memberId: Mapped[int] = mapped_column(BIGINT)
    completed: Mapped[Optional[dict]] = mapped_column(JSON)
    createdDt: Mapped[datetime.datetime] = mapped_column(TIMESTAMP, server_default=text('CURRENT_TIMESTAMP'))
    updatedDt: Mapped[datetime.datetime] = mapped_column(TIMESTAMP, server_default=text('CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP'))

    Community_: Mapped['Community'] = relationship('Community', back_populates='CommunityUser')
    User_: Mapped['User'] = relationship('User', back_populates='CommunityUser')


class NotificationUser(Base):
    __tablename__ = 'NotificationUser'
    __table_args__ = (
        ForeignKeyConstraint(['notificationId'], ['Notification.notificationId'], ondelete='CASCADE', onupdate='CASCADE', name='notificationuser_ibfk_1'),
        ForeignKeyConstraint(['userId'], ['User.userId'], ondelete='CASCADE', onupdate='CASCADE', name='notificationuser_ibfk_2'),
        Index('notificationUserId', 'notificationUserId', unique=True),
        Index('unique_notification_user', 'notificationId', 'userId', unique=True),
        Index('userId', 'userId')
    )

    notificationUserId: Mapped[int] = mapped_column(BIGINT, primary_key=True)
    notificationId: Mapped[int] = mapped_column(BIGINT)
    userId: Mapped[int] = mapped_column(BIGINT)
    markRead: Mapped[bool] = mapped_column(Boolean, server_default=text("'0'"))
    archived: Mapped[bool] = mapped_column(Boolean, server_default=text("'0'"))
    deleted: Mapped[bool] = mapped_column(Boolean, server_default=text("'0'"))
    pushNotification: Mapped[bool] = mapped_column(Boolean, server_default=text("'0'"))
    createdDt: Mapped[datetime.datetime] = mapped_column(TIMESTAMP, server_default=text('CURRENT_TIMESTAMP'))
    updatedDt: Mapped[datetime.datetime] = mapped_column(TIMESTAMP, server_default=text('CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP'))

    Notification_: Mapped['Notification'] = relationship('Notification', back_populates='NotificationUser')
    User_: Mapped['User'] = relationship('User', back_populates='NotificationUser')


class Collectible(Base):
    __tablename__ = 'Collectible'
    __table_args__ = (
        ForeignKeyConstraint(['categoryId'], ['Category.categoryId'], ondelete='CASCADE', onupdate='CASCADE', name='collectible_ibfk_1'),
        ForeignKeyConstraint(['collectionId'], ['Collection.collectionId'], ondelete='CASCADE', onupdate='CASCADE', name='collectible_ibfk_3'),
        ForeignKeyConstraint(['communityId'], ['Community.communityId'], ondelete='CASCADE', onupdate='CASCADE', name='collectible_ibfk_4'),
        ForeignKeyConstraint(['projectId'], ['Project.projectId'], ondelete='CASCADE', onupdate='CASCADE', name='collectible_ibfk_2'),
        Index('categoryId', 'categoryId'),
        Index('collectibleId', 'collectibleId', unique=True),
        Index('collectionId', 'collectionId'),
        Index('communityId', 'communityId'),
        Index('projectId', 'projectId')
    )

    collectibleId: Mapped[int] = mapped_column(BIGINT, primary_key=True)
    collectionId: Mapped[int] = mapped_column(BIGINT)
    categoryId: Mapped[int] = mapped_column(BIGINT)
    projectId: Mapped[int] = mapped_column(BIGINT)
    communityId: Mapped[int] = mapped_column(BIGINT)
    label: Mapped[dict[str, str]] = mapped_column(JSON)
    name: Mapped[dict[str, str]] = mapped_column(JSON)
    createdDt: Mapped[datetime.datetime] = mapped_column(TIMESTAMP, server_default=text('CURRENT_TIMESTAMP'))
    updatedDt: Mapped[datetime.datetime] = mapped_column(TIMESTAMP, server_default=text('CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP'))
    active: Mapped[bool] = mapped_column(Boolean, server_default=text("'1'"))
    description: Mapped[Optional[dict[str, str]]] = mapped_column(JSON)
    imageRef: Mapped[Optional[dict]] = mapped_column(JSON)
    vidRef: Mapped[Optional[dict]] = mapped_column(JSON)
    qrRef: Mapped[Optional[dict]] = mapped_column(JSON)
    embedRef: Mapped[Optional[dict]] = mapped_column(JSON)
    circulation: Mapped[Optional[int]] = mapped_column(INTEGER)
    publicationDate: Mapped[Optional[datetime.datetime]] = mapped_column(TIMESTAMP)
    isOnBlockchain: Mapped[Optional[bool]] = mapped_column(Boolean)
    blockchainCollectibleAddress: Mapped[Optional[str]] = mapped_column(String(255))
    price: Mapped[Optional[dict]] = mapped_column(JSON)

    Category_: Mapped['Category'] = relationship('Category', back_populates='Collectible')
    Collection_: Mapped['Collection'] = relationship('Collection', back_populates='Collectible')
    Community_: Mapped['Community'] = relationship('Community', back_populates='Collectible')
    Project_: Mapped['Project'] = relationship('Project', back_populates='Collectible')
    CollectibleSponsor: Mapped[List['CollectibleSponsor']] = relationship('CollectibleSponsor', back_populates='Collectible_')
    UserCollectible: Mapped[List['UserCollectible']] = relationship('UserCollectible', back_populates='Collectible_')
    DistributionCollectible: Mapped[List['DistributionCollectible']] = relationship('DistributionCollectible', back_populates='Collectible_')


class Mission(Base):
    __tablename__ = 'Mission'
    __table_args__ = (
        ForeignKeyConstraint(['collectionId'], ['Collection.collectionId'], ondelete='CASCADE', onupdate='CASCADE', name='mission_ibfk_1'),
        ForeignKeyConstraint(['rewardId'], ['Collectible.collectibleId'], ondelete='SET NULL', onupdate='CASCADE', name='mission_ibfk_2'),
        Index('collectionId', 'collectionId'),
        Index('missionId', 'missionId', unique=True)
    )

    missionId: Mapped[int] = mapped_column(BIGINT, primary_key=True)
    collectionId: Mapped[int] = mapped_column(BIGINT)
    title: Mapped[dict[str, str]] = mapped_column(JSON)
    goal: Mapped[int] = mapped_column(INTEGER)
    timer: Mapped[bool] = mapped_column(Boolean, server_default=text("'0'"))
    createdDt: Mapped[datetime.datetime] = mapped_column(TIMESTAMP, server_default=text('CURRENT_TIMESTAMP'))
    updatedDt: Mapped[datetime.datetime] = mapped_column(TIMESTAMP, server_default=text('CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP'))
    description: Mapped[Optional[dict[str, str]]] = mapped_column(JSON)
    reward: Mapped[Optional[dict[str, str]]] = mapped_column(JSON)
    rewardId: Mapped[Optional[int]] = mapped_column(BIGINT)
    endDate: Mapped[Optional[datetime.datetime]] = mapped_column(TIMESTAMP)
    imgRef: Mapped[Optional[dict]] = mapped_column(JSON)
    vidRef: Mapped[Optional[dict]] = mapped_column(JSON)
    qrRef: Mapped[Optional[dict]] = mapped_column(JSON)
    embedRef: Mapped[Optional[dict]] = mapped_column(JSON)

    Collection_: Mapped['Collection'] = relationship('Collection', back_populates='Mission')
    MissionUser: Mapped[List['MissionUser']] = relationship('MissionUser', back_populates='Mission_')


class CollectibleSponsor(Base):
    __tablename__ = 'CollectibleSponsor'
    __table_args__ = (
        ForeignKeyConstraint(['collectibleId'], ['Collectible.collectibleId'], ondelete='CASCADE', onupdate='CASCADE', name='collectiblesponsor_ibfk_1'),
        ForeignKeyConstraint(['sponsorId'], ['Sponsor.sponsorId'], ondelete='CASCADE', onupdate='CASCADE', name='collectiblesponsor_ibfk_2'),
        Index('collectibleId', 'collectibleId'),
        Index('collectibleSponsorId', 'collectibleSponsorId', unique=True),
        Index('sponsorId', 'sponsorId')
    )

    collectibleSponsorId: Mapped[int] = mapped_column(BIGINT, primary_key=True)
    collectibleId: Mapped[int] = mapped_column(BIGINT)
    sponsorId: Mapped[int] = mapped_column(BIGINT)
    active: Mapped[bool] = mapped_column(Boolean, server_default=text("'1'"))
    sponsorMessage: Mapped[Optional[dict[str, str]]] = mapped_column(JSON)

    Collectible_: Mapped['Collectible'] = relationship('Collectible', back_populates='CollectibleSponsor')
    Sponsor_: Mapped['Sponsor'] = relationship('Sponsor', back_populates='CollectibleSponsor')


class MissionUser(Base):
    __tablename__ = 'MissionUser'
    __table_args__ = (
        ForeignKeyConstraint(['missionId'], ['Mission.missionId'], ondelete='CASCADE', onupdate='CASCADE', name='missionuser_ibfk_2'),
        ForeignKeyConstraint(['userId'], ['User.userId'], ondelete='CASCADE', onupdate='CASCADE', name='missionuser_ibfk_1'),
        Index('missionId', 'missionId'),
        Index('missionUserId', 'missionUserId', unique=True),
        Index('unique_user_mission', 'userId', 'missionId', unique=True)
    )

    missionUserId: Mapped[int] = mapped_column(BIGINT, primary_key=True)
    userId: Mapped[int] = mapped_column(BIGINT)
    missionId: Mapped[int] = mapped_column(BIGINT)
    progress: Mapped[int] = mapped_column(INTEGER, server_default=text("'0'"))
    completed: Mapped[bool] = mapped_column(Boolean, server_default=text("'0'"))
    rewardClaimed: Mapped[bool] = mapped_column(Boolean, server_default=text("'0'"))
    status: Mapped[Optional[str]] = mapped_column(String(255))
    dateCompleted: Mapped[Optional[datetime.datetime]] = mapped_column(TIMESTAMP)

    Mission_: Mapped['Mission'] = relationship('Mission', back_populates='MissionUser')
    User_: Mapped['User'] = relationship('User', back_populates='MissionUser')
    MissionUserData: Mapped[List['MissionUserData']] = relationship('MissionUserData', back_populates='MissionUser_')


class UserCollectible(Base):
    __tablename__ = 'UserCollectible'
    __table_args__ = (
        ForeignKeyConstraint(['collectibleId'], ['Collectible.collectibleId'], ondelete='CASCADE', onupdate='CASCADE', name='usercollectible_ibfk_1'),
        ForeignKeyConstraint(['ownerId'], ['User.userId'], ondelete='CASCADE', onupdate='CASCADE', name='usercollectible_ibfk_2'),
        ForeignKeyConstraint(['previousOwnerId'], ['User.userId'], ondelete='SET NULL', onupdate='CASCADE', name='usercollectible_ibfk_3'),
        Index('collectibleId', 'collectibleId'),
        Index('previousOwnerId', 'previousOwnerId'),
        Index('unique_owner_collectible_mint', 'ownerId', 'collectibleId', 'mint', unique=True),
        Index('userCollectibleId', 'userCollectibleId', unique=True)
    )

    userCollectibleId: Mapped[int] = mapped_column(BIGINT, primary_key=True)
    ownerId: Mapped[int] = mapped_column(BIGINT)
    collectibleId: Mapped[int] = mapped_column(BIGINT)
    mint: Mapped[int] = mapped_column(INTEGER)
    createdDt: Mapped[datetime.datetime] = mapped_column(TIMESTAMP, server_default=text('CURRENT_TIMESTAMP'))
    updatedDt: Mapped[datetime.datetime] = mapped_column(TIMESTAMP, server_default=text('CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP'))
    active: Mapped[bool] = mapped_column(Boolean, server_default=text("'1'"))
    favorite: Mapped[bool] = mapped_column(Boolean, server_default=text("'0'"))
    previousOwnerId: Mapped[Optional[int]] = mapped_column(BIGINT)
    lastTransferredDt: Mapped[Optional[datetime.datetime]] = mapped_column(TIMESTAMP)
    trade: Mapped[Optional[bool]] = mapped_column(Boolean)
    points: Mapped[Optional[int]] = mapped_column(Integer)
    qrCode: Mapped[Optional[dict]] = mapped_column(JSON)

    Collectible_: Mapped['Collectible'] = relationship('Collectible', back_populates='UserCollectible')
    User_: Mapped['User'] = relationship('User', foreign_keys=[ownerId], back_populates='UserCollectible')
    User1: Mapped[Optional['User']] = relationship('User', foreign_keys=[previousOwnerId], back_populates='UserCollectible_')


class MissionUserData(Base):
    __tablename__ = 'MissionUserData'
    __table_args__ = (
        ForeignKeyConstraint(['missionUserId'], ['MissionUser.missionUserId'], ondelete='CASCADE', onupdate='CASCADE', name='missionuserdata_ibfk_1'),
        Index('missionUserDataId', 'missionUserDataId', unique=True),
        Index('missionUserId', 'missionUserId')
    )

    missionUserDataId: Mapped[int] = mapped_column(BIGINT, primary_key=True)
    missionUserId: Mapped[int] = mapped_column(BIGINT)
    createdDt: Mapped[datetime.datetime] = mapped_column(TIMESTAMP, server_default=text('CURRENT_TIMESTAMP'))
    action: Mapped[Optional[str]] = mapped_column(String(255))
    status: Mapped[Optional[str]] = mapped_column(String(255))

    MissionUser_: Mapped['MissionUser'] = relationship('MissionUser', back_populates='MissionUserData')


class Distribution(Base):
    __tablename__ = 'Distribution'
    __table_args__ = (
        ForeignKeyConstraint(['projectId'], ['Project.projectId'], ondelete='CASCADE', onupdate='CASCADE', name='distribution_ibfk_1'),
        ForeignKeyConstraint(['collectionId'], ['Collection.collectionId'], ondelete='CASCADE', onupdate='CASCADE', name='distribution_ibfk_2'),
        Index('distributionId', 'distributionId', unique=True),
        Index('projectId', 'projectId'),
        Index('collectionId', 'collectionId')
    )

    distributionId: Mapped[int] = mapped_column(BIGINT, primary_key=True)
    projectId: Mapped[int] = mapped_column(BIGINT)
    collectionId: Mapped[Optional[int]] = mapped_column(BIGINT)
    name: Mapped[dict] = mapped_column(JSON)
    type: Mapped['DistributionTypeEnum'] = mapped_column(Enum('voucher', 'coupon', 'deal', 'scan', name='distributionType'))
    description: Mapped[Optional[dict]] = mapped_column(JSON)
    isTimed: Mapped[bool] = mapped_column(Boolean, server_default=text("'0'"))
    isLimited: Mapped[bool] = mapped_column(Boolean, server_default=text("'0'"))
    isNewUserReward: Mapped[bool] = mapped_column(Boolean, server_default=text("'0'"))
    limitedQty: Mapped[Optional[int]] = mapped_column(INTEGER)
    isRandom: Mapped[bool] = mapped_column(Boolean, server_default=text("'0'"))
    startDate: Mapped[datetime.datetime] = mapped_column(TIMESTAMP)
    endDate: Mapped[datetime.datetime] = mapped_column(TIMESTAMP)
    isUniqueCollectible: Mapped[Optional[bool]] = mapped_column(Boolean)
    createdDt: Mapped[datetime.datetime] = mapped_column(TIMESTAMP, server_default=text('CURRENT_TIMESTAMP'))
    updatedDt: Mapped[datetime.datetime] = mapped_column(TIMESTAMP, server_default=text('CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP'))

    Project_: Mapped['Project'] = relationship('Project', back_populates='Distribution')
    Collection_: Mapped[Optional['Collection']] = relationship('Collection', back_populates='Distribution')
    DistributionCode: Mapped[List['DistributionCode']] = relationship('DistributionCode', back_populates='Distribution_')
    DistributionCollectible: Mapped[List['DistributionCollectible']] = relationship('DistributionCollectible', back_populates='Distribution_')

class DistributionCode(Base):
    __tablename__ = 'DistributionCode'
    __table_args__ = (
        ForeignKeyConstraint(['distributionId'], ['Distribution.distributionId'], ondelete='CASCADE', onupdate='CASCADE', name='distributioncode_ibfk_1'),
        Index('distributionCodeId', 'distributionCodeId', unique=True),
        Index('distributionId', 'distributionId'),
        Index('code', 'code')
    )

    distributionCodeId: Mapped[int] = mapped_column(BIGINT, primary_key=True)
    distributionId: Mapped[int] = mapped_column(BIGINT)
    code: Mapped[str] = mapped_column(String(255), unique=True)
    qrCode: Mapped[Optional[dict]] = mapped_column(JSON)
    isMultiUse: Mapped[bool] = mapped_column(Boolean, server_default=text("'0'"))
    multiUseQty: Mapped[Optional[int]] = mapped_column(INTEGER)
    createdDt: Mapped[datetime.datetime] = mapped_column(TIMESTAMP, server_default=text('CURRENT_TIMESTAMP'))
    updatedDt: Mapped[datetime.datetime] = mapped_column(TIMESTAMP, server_default=text('CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP'))

    Distribution_: Mapped['Distribution'] = relationship('Distribution', back_populates='DistributionCode')
    DistributionCodeUser: Mapped[List['DistributionCodeUser']] = relationship('DistributionCodeUser', back_populates='DistributionCode_')

class DistributionCodeUser(Base):
    __tablename__ = 'DistributionCodeUser'
    __table_args__ = (
        ForeignKeyConstraint(['distributionCodeId'], ['DistributionCode.distributionCodeId'], ondelete='CASCADE', onupdate='CASCADE', name='distributioncodeuser_ibfk_1'),
        ForeignKeyConstraint(['userId'], ['User.userId'], ondelete='CASCADE', onupdate='CASCADE', name='distributioncodeuser_ibfk_2'),
        ForeignKeyConstraint(['previousOwnerId'], ['User.userId'], ondelete='SET NULL', onupdate='CASCADE', name='distributioncodeuser_ibfk_3'),
        Index('distributionCodeUserId', 'distributionCodeUserId', unique=True),
        Index('distributionCodeId', 'distributionCodeId'),
        Index('userId', 'userId')
    )

    distributionCodeUserId: Mapped[int] = mapped_column(BIGINT, primary_key=True)
    userId: Mapped[int] = mapped_column(BIGINT)
    distributionCodeId: Mapped[int] = mapped_column(BIGINT)
    previousOwnerId: Mapped[Optional[int]] = mapped_column(BIGINT)
    redeemed: Mapped[bool] = mapped_column(Boolean, server_default=text("'0'"))
    redeemedDate: Mapped[Optional[datetime.datetime]] = mapped_column(TIMESTAMP)
    collectibleReceived: Mapped[Optional[dict]] = mapped_column(JSON)
    createdDt: Mapped[datetime.datetime] = mapped_column(TIMESTAMP, server_default=text('CURRENT_TIMESTAMP'))
    updatedDt: Mapped[datetime.datetime] = mapped_column(TIMESTAMP, server_default=text('CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP'))

    DistributionCode_: Mapped['DistributionCode'] = relationship('DistributionCode', back_populates='DistributionCodeUser')
    User_: Mapped['User'] = relationship('User', foreign_keys=[userId], back_populates='DistributionCodeUser')
    User1: Mapped[Optional['User']] = relationship('User', foreign_keys=[previousOwnerId], back_populates='DistributionCodeUser_')


class DistributionCollectible(Base):
    __tablename__ = 'DistributionCollectible'
    __table_args__ = (
        ForeignKeyConstraint(['distributionId'], ['Distribution.distributionId'], ondelete='CASCADE', onupdate='CASCADE', name='distributioncollectible_ibfk_1'),
        ForeignKeyConstraint(['collectibleId'], ['Collectible.collectibleId'], ondelete='CASCADE', onupdate='CASCADE', name='distributioncollectible_ibfk_2'),
        Index('distributionCollectibleId', 'distributionCollectibleId', unique=True),
        Index('distributionId', 'distributionId'),
        Index('collectibleId', 'collectibleId')
    )

    distributionCollectibleId: Mapped[int] = mapped_column(BIGINT, primary_key=True)
    collectibleId: Mapped[int] = mapped_column(BIGINT)
    distributionId: Mapped[int] = mapped_column(BIGINT)
    createdDt: Mapped[datetime.datetime] = mapped_column(TIMESTAMP, server_default=text('CURRENT_TIMESTAMP'))
    updatedDt: Mapped[datetime.datetime] = mapped_column(TIMESTAMP, server_default=text('CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP'))

    Distribution_: Mapped['Distribution'] = relationship('Distribution', back_populates='DistributionCollectible')
    Collectible_: Mapped['Collectible'] = relationship('Collectible', back_populates='DistributionCollectible')