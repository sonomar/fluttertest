CREATE DATABASE IF NOT EXISTS deins_db_local;
USE deins_db_local;

-- User Table
CREATE TABLE IF NOT EXISTS User (
    userId SERIAL PRIMARY KEY,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    userRank JSON,
    username VARCHAR(255) UNIQUE,
    passwordHashed VARCHAR(255) NOT NULL,
    profileImg VARCHAR(255),
    createdDt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedDt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    authToken TEXT,
    deviceId VARCHAR(255),
    userType ENUM('unregistered', 'username', 'email', 'admin') DEFAULT 'unregistered',
    lastLoggedIn TIMESTAMP
);

-- Category Table
CREATE TABLE IF NOT EXISTS Category (
    categoryId SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    createdDt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedDt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Community Table (Creating this before tables that reference it)
CREATE TABLE IF NOT EXISTS Community (
    communityId SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    imageRef JSON,
    vidRef JSON,
    qrRef JSON,
    embedRef JSON,
    createdDt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedDt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    active BOOLEAN NOT NULL DEFAULT TRUE
);

-- Collection Table (Creating this before tables that reference it)
CREATE TABLE IF NOT EXISTS Collection (
    collectionId SERIAL PRIMARY KEY,
    communityId BIGINT UNSIGNED NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    imageRef JSON,
    vidRef JSON,
    qrRef JSON,
    embedRef JSON,
    createdDt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedDt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    FOREIGN KEY (communityId) REFERENCES Community(communityId) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Project Table
CREATE TABLE IF NOT EXISTS Project (
    projectId SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    attributed JSON NOT NULL,
    createdDt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedDt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    location VARCHAR(255),
    active BOOLEAN NOT NULL DEFAULT TRUE
);

-- Collectible Table
CREATE TABLE IF NOT EXISTS Collectible (
    collectibleId SERIAL PRIMARY KEY,
    collectionId BIGINT UNSIGNED NOT NULL,
    categoryId BIGINT UNSIGNED NOT NULL,
    projectId BIGINT UNSIGNED NOT NULL,
    communityId BIGINT UNSIGNED NOT NULL,
    label VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    imageRef JSON,
    vidRef JSON,
    qrRef JSON,
    embedRef JSON,
    createdDt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedDt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    circulation INT UNSIGNED,
    publicationDate TIMESTAMP,
    FOREIGN KEY (categoryId) REFERENCES Category(categoryId) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (projectId) REFERENCES Project(projectId) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (collectionId) REFERENCES Collection(collectionId) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (communityId) REFERENCES Community(communityId) ON DELETE CASCADE ON UPDATE CASCADE
);

-- UserCollectible Table (Join Table)
CREATE TABLE IF NOT EXISTS UserCollectible (
    userCollectibleId SERIAL PRIMARY KEY,
    ownerId BIGINT UNSIGNED NOT NULL,
    collectibleId BIGINT UNSIGNED NOT NULL,
    previousOwnerId BIGINT UNSIGNED,
    mint INT UNSIGNED NOT NULL,
    createdDt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedDt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    lastTransferredDt TIMESTAMP,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    favorite BOOLEAN NOT NULL DEFAULT FALSE,
    FOREIGN KEY (collectibleId) REFERENCES Collectible(collectibleId) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (ownerId) REFERENCES User(userId) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (previousOwnerId) REFERENCES User(userId) ON DELETE SET NULL ON UPDATE CASCADE,
    UNIQUE KEY unique_owner_collectible_mint (ownerId, collectibleId, mint)
);

-- CommunityUser Table
CREATE TABLE IF NOT EXISTS CommunityUser (
    communityUserId SERIAL PRIMARY KEY,
    communityId BIGINT UNSIGNED NOT NULL,
    memberId BIGINT UNSIGNED NOT NULL,
    createdDt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedDt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (communityId) REFERENCES Community(communityId) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (memberId) REFERENCES User(userId) ON DELETE CASCADE ON UPDATE CASCADE,
    UNIQUE KEY unique_community_member (communityId, memberId)
);

-- Sponsor Table
CREATE TABLE IF NOT EXISTS Sponsor (
    sponsorId SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    organization VARCHAR(255),
    urls JSON,
    description TEXT,
    imageRef JSON,
    vidRef JSON,
    qrRef JSON,
    embedRef JSON,
    createdDt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedDt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    sponsorCity VARCHAR(255),
    sponsorCountry VARCHAR(255),
    sponsorZip VARCHAR(20),
    primaryContactName VARCHAR(255),
    primaryContactEmail VARCHAR(255),
    primaryContactPhone BIGINT
);

-- CollectibleSponsor Table (Join Table)
CREATE TABLE IF NOT EXISTS CollectibleSponsor (
    collectibleSponsorId SERIAL PRIMARY KEY,
    collectibleId BIGINT UNSIGNED NOT NULL,
    sponsorId BIGINT UNSIGNED NOT NULL,
    sponsorMessage TEXT,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    FOREIGN KEY (collectibleId) REFERENCES Collectible(collectibleId) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (sponsorId) REFERENCES Sponsor(sponsorId) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Notification Table
CREATE TABLE IF NOT EXISTS Notification (
    notificationId SERIAL PRIMARY KEY,
    header VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    link JSON,
    pushNotification BOOLEAN NOT NULL DEFAULT FALSE,
    private BOOLEAN NOT NULL DEFAULT FALSE,
    imgRef JSON,
    vidRef JSON,
    qrRef JSON,
    embedRef JSON,
    createdDt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedDt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    active BOOLEAN NOT NULL DEFAULT TRUE
);

-- NotificationUser Table
CREATE TABLE IF NOT EXISTS NotificationUser (
    notificationUserId SERIAL PRIMARY KEY,
    notificationId BIGINT UNSIGNED NOT NULL,
    userId BIGINT UNSIGNED NOT NULL,
    markRead BOOLEAN NOT NULL DEFAULT FALSE,
    archived BOOLEAN NOT NULL DEFAULT FALSE,
    deleted BOOLEAN NOT NULL DEFAULT FALSE,
    pushNotification BOOLEAN NOT NULL DEFAULT FALSE,
    createdDt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedDt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (notificationId) REFERENCES Notification(notificationId) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (userId) REFERENCES User(userId) ON DELETE CASCADE ON UPDATE CASCADE,
    UNIQUE KEY unique_notification_user (notificationId, userId)
);

-- NewsPost Table
CREATE TABLE IF NOT EXISTS NewsPost (
    newsPostId SERIAL PRIMARY KEY,
    header VARCHAR(255) NOT NULL,
    body TEXT NOT NULL,
    shortBody TEXT NOT NULL,
    postDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    type VARCHAR(255),
    createdDt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedDt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    imgRef JSON,
    vidRef JSON,
    qrRef JSON,
    embedRef JSON,
    active BOOLEAN NOT NULL DEFAULT TRUE
);

-- Mission Table
CREATE TABLE IF NOT EXISTS Mission (
    missionId SERIAL PRIMARY KEY,
    collectionId BIGINT UNSIGNED NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    reward VARCHAR(255),
    goal INT UNSIGNED NOT NULL,
    timer BOOLEAN NOT NULL DEFAULT FALSE,
    endDate TIMESTAMP,
    imgRef JSON,
    vidRef JSON,
    qrRef JSON,
    embedRef JSON,
    createdDt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedDt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (collectionId) REFERENCES Collection(collectionId) ON DELETE CASCADE ON UPDATE CASCADE
);

-- MissionUser Table
CREATE TABLE IF NOT EXISTS MissionUser (
    missionUserId SERIAL PRIMARY KEY,
    userId BIGINT UNSIGNED NOT NULL,
    missionId BIGINT UNSIGNED NOT NULL,
    progress INT UNSIGNED NOT NULL DEFAULT 0,
    status VARCHAR(255),
    completed BOOLEAN NOT NULL DEFAULT FALSE,
    dateCompleted TIMESTAMP,
    rewardClaimed BOOLEAN NOT NULL DEFAULT FALSE,
    FOREIGN KEY (userId) REFERENCES User(userId) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (missionId) REFERENCES Mission(missionId) ON DELETE CASCADE ON UPDATE CASCADE,
    UNIQUE KEY unique_user_mission (userId, missionId)
);

-- MissionUserData Table
CREATE TABLE IF NOT EXISTS MissionUserData (
    missionUserDataId SERIAL PRIMARY KEY,
    missionUserId BIGINT UNSIGNED NOT NULL,
    action VARCHAR(255),
    status VARCHAR(255),
    createdDt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (missionUserId) REFERENCES MissionUser(missionUserId) ON DELETE CASCADE ON UPDATE CASCADE
);

-- CommunityChallenge Table
CREATE TABLE IF NOT EXISTS CommunityChallenge (
    communityChallengeId SERIAL PRIMARY KEY,
    communityId BIGINT UNSIGNED NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    reward VARCHAR(255),
    goal INT UNSIGNED NOT NULL,
    timer BOOLEAN NOT NULL DEFAULT FALSE,
    startDate TIMESTAMP,
    endDate TIMESTAMP,
    imgRef JSON,
    vidRef JSON,
    qrRef JSON,
    embedRef VARCHAR(255),
    createdDt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedDt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (communityId) REFERENCES Community(communityId) ON DELETE CASCADE ON UPDATE CASCADE
);