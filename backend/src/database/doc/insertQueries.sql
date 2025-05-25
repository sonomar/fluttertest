USE kloppocar;
-- Inserting data into User table
INSERT INTO User (email, userRank, username, passwordHashed, profileImg, userType, lastLoggedIn) VALUES
('user1@example.com', '{"level": 1, "points": 10}', 'user_one', '$2a$10$xxxxxxxxxxxxxxxxxxxxxxxxxxxxx', 'https://via.placeholder.com/150/FFC107', 'username', NOW() - INTERVAL 1 DAY),
('test@test.de', '{"level": 3, "points": 55}', 'test_user', '$2a$10$yyyyyyyyyyyyyyyyyyyyyyyyyyyyy', 'https://via.placeholder.com/150/4CAF50', 'username', NOW() - INTERVAL 2 DAY),
('admin@kloppocar.com', '{"role": "administrator"}', 'admin_user', '$2a$10$zzzzzzzzzzzzzzzzzzzzzzzzzzz', 'https://via.placeholder.com/150/F44336', 'admin', NOW());

-- Inserting data into Category table
INSERT INTO Category (name) VALUES
('Car Part'),
('Accessory'),
('Event'),
('Memorabilia');

-- Inserting data into Community table
INSERT INTO Community (title, description, imageRef) VALUES
('Classic Car Enthusiasts', 'A community for lovers of classic automobiles.', '["https://via.placeholder.com/300/00BCD4"]'),
('Electric Vehicle Owners Berlin', 'Connecting EV owners in the Berlin area.', '["https://via.placeholder.com/300/8BC34A"]'),
('Kloppocar Garage', 'Official community for Kloppocar project discussions.', '["https://via.placeholder.com/300/9C27B0"]');

-- Inserting data into Collection table
INSERT INTO Collection (communityId, name, description, imageRef) VALUES
(1, 'Vintage Wheels Collection', 'A collection of wheels from classic cars.', '["https://via.placeholder.com/200/FF9800"]'),
(2, 'Berlin EV Meetups', 'Photos and info from our electric vehicle meetups in Berlin.', '["https://via.placeholder.com/200/E91E63"]'),
(3, 'Kloppocar First Edition', 'The first collectibles released by Kloppocar.', '["https://via.placeholder.com/200/673AB7"]'),
(1, 'Classic Car Badges', 'A collection of badges from different classic car manufacturers.', '["https://via.placeholder.com/200/CDDC39"]');

-- Inserting data into Project table
INSERT INTO Project (name, attributed, location) VALUES
('Project Restoration 1967 Mustang', '{"owner": "John Doe", "startDate": "2024-05-15"}', 'Berlin'),
('Electric Vehicle Adoption Initiative', '{"sponsor": "Siemens", "goal": "1000 new EVs"}', 'Greater Berlin Area'),
('Kloppocar Genesis Collection', '{"artist": "AI Generated", "releaseDate": "2025-01-01"}', 'Online');

-- Inserting data into Collectible table
INSERT INTO Collectible (collectionId, categoryId, projectId, communityId, label, name, description, imageRef, circulation, publicationDate) VALUES
(1, 1, 1, 1, 'Wheel', '1967 Mustang Hubcap', 'Original hubcap from a 1967 Ford Mustang.', '["https://via.placeholder.com/100/F44336"]', 500, '2024-08-20'),
(2, 3, 2, 2, 'Event Photo', 'Berlin EV Meetup - July 2024', 'Photo from the July 2024 electric vehicle meetup.', '["https://via.placeholder.com/100/3F51B5"]', 1000, '2024-07-25'),
(3, 4, 3, 3, 'Digital Art', 'Kloppocar #001', 'First digital collectible from the Kloppocar project.', '["https://via.placeholder.com/100/009688"]', 12, '2025-01-01'),
(1, 4, 1, 1, 'Badge', 'Ford Mustang Emblem', 'Original Ford Mustang hood emblem.', '["https://via.placeholder.com/100/E64A19"]', 250, '2024-11-10');

-- Inserting data into UserCollectible table
INSERT INTO UserCollectible (ownerId, collectibleId, mint) VALUES
(1, 1, 1),
(2, 2, 5),
(3, 3, 1),
(1, 4, 10),
(2, 1, 2);

-- Inserting data into CommunityUser table
INSERT INTO CommunityUser (communityId, memberId) VALUES
(1, 1),
(2, 2),
(3, 3),
(1, 3),
(2, 1);

-- Inserting data into Sponsor table
INSERT INTO Sponsor (name, organization, urls, description, imageRef, sponsorCity, sponsorCountry) VALUES
('Auto Parts Plus', 'Independent Auto Supply', '{"website": "https://www.autopartsplus.com"}', 'Your local source for quality auto parts.', '["https://via.placeholder.com/120/FFEB3B"]', 'Berlin', 'Germany'),
('E-Mobility Solutions Inc.', 'Leading EV Technology Company', '{"website": "https://www.emobilitysolutions.com", "twitter": "@EMobility"}', 'Driving the future of electric mobility.', '["https://via.placeholder.com/120/00E676"]', 'Munich', 'Germany'),
('Kloppocar Foundation', 'Supporting automotive heritage and innovation', '{"website": "https://www.kloppocar.org", "instagram": "@kloppocar_official"}', 'Dedicated to preserving and promoting automotive culture.', '["https://via.placeholder.com/120/795548"]', 'Berlin', 'Germany');

-- Inserting data into CollectibleSponsor table
INSERT INTO CollectibleSponsor (collectibleId, sponsorId, sponsorMessage) VALUES
(1, 1, 'Proudly sponsoring the restoration of classic vehicles.'),
(2, 2, 'Supporting the electric vehicle community in Berlin.'),
(3, 3, 'This collectible is brought to you by the Kloppocar Foundation.');

-- Inserting data into Notification table
INSERT INTO Notification (header, content, link) VALUES
('New Collectible Available!', 'A new vintage wheel collectible has been added to the Classic Wheels Collection.', '{"url": "/collectibles/123"}'),
('Berlin EV Meetup Reminder', 'Don\'t forget the EV meetup next Saturday!', '{"url": "/events/456"}'),
('Welcome to Kloppocar!', 'Thank you for joining the Kloppocar community.', '{"url": "/profile"}');

INSERT INTO Notification (header, content, private) VALUES
('Private Message', 'Hey, check out this cool car!', TRUE);

-- Inserting data into NotificationUser table
INSERT INTO NotificationUser (notificationId, userId, markRead) VALUES
(1, 1, TRUE),
(2, 2, FALSE),
(3, 3, FALSE);

-- Inserting data into NotificationUser table for the private notification
INSERT INTO NotificationUser (notificationId, userId)
SELECT (SELECT notificationId FROM Notification WHERE header = 'Private Message'), 1;

-- Inserting data into NewsPost table
INSERT INTO NewsPost (header, body, shortBody, type, imgRef) VALUES
('Classic Car Show in Berlin', 'Details about the upcoming classic car show at Messe Berlin...', 'Upcoming car show at Messe Berlin.', 'event', '["https://via.placeholder.com/400/FFC107"]'),
('Electric Vehicle Incentives Updated', 'New government incentives for purchasing electric vehicles in Germany...', 'New EV incentives announced.', 'news', '["https://via.placeholder.com/400/8BC34A"]'),
('Kloppocar Platform Launch', 'We are excited to announce the official launch of the Kloppocar platform!', 'Kloppocar platform is now live!', 'announcement', '["https://via.placeholder.com/400/9C27B0"]');

-- Inserting data into Mission table
INSERT INTO Mission (collectionId, title, description, reward, goal) VALUES
(1, 'Wheel Enthusiast', 'Collect 3 different vintage wheel collectibles.', 'Exclusive badge', 3),
(2, 'EV Community Member', 'Attend 2 Berlin EV meetups.', 'Early access to next event info', 2),
(3, 'Kloppocar Explorer', 'View 5 different Kloppocar collectibles.', 'Unique profile banner', 5);

-- Inserting data into MissionUser table
INSERT INTO MissionUser (userId, missionId, progress, completed) VALUES
(1, 1, 1, FALSE),
(2, 2, 2, TRUE),
(3, 3, 3, FALSE);

-- Inserting data into MissionUserData table
INSERT INTO MissionUserData (missionUserId, action) VALUES
(1, 'Viewed collectible #1'),
(2, 'Attended meetup on 2025-04-15'),
(2, 'Attended meetup on 2025-04-29'),
(3, 'Viewed collectible #001'),
(3, 'Viewed collectible #002');

-- Inserting data into CommunityChallenge table
INSERT INTO CommunityChallenge (communityId, title, description, reward, goal, startDate, endDate, imgRef) VALUES
(1, 'Classic Car Photo Contest', 'Share your best photo of a classic car.', 'Featured on community page', 10, '2025-05-05', '2025-05-20', '["https://via.placeholder.com/600/00BCD4"]'),
(2, 'EV Range Leaderboard - May', 'Log your longest single charge EV range this month.', 'Bragging rights and a digital trophy', 5, '2025-05-01', '2025-05-31', '["https://via.placeholder.com/600/8BC34A"]'),
(3, 'Kloppocar Trivia Challenge', 'Test your knowledge about Kloppocar collectibles.', 'Exclusive Kloppocar collectible', 3, '2025-05-10', '2025-05-17', '["https://via.placeholder.com/600/9C27B0"]');