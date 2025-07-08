-- This SQL script creates default notification user entries for all existing users.
-- It ensures that each user has a 'NotificationUser' entry linked to 'notificationId = 1',
-- but only if such an entry does not already exist for that user.
-- This is useful for backfilling data after a new notification type is introduced.

INSERT IGNORE INTO NotificationUser (notificationId, userId, markRead, archived, deleted, pushNotification)
SELECT
    1 AS notificationId, -- The specific notification ID to link (as per your trigger)
    u.userId,            -- The ID of the existing user
    FALSE AS markRead,   -- Default: not read
    FALSE AS archived,   -- Default: not archived
    FALSE AS deleted,    -- Default: not deleted
    FALSE AS pushNotification -- Default: push notifications off
FROM
    User u;

-- Note: This query uses INSERT IGNORE. For INSERT IGNORE to correctly prevent duplicates,
-- you should have a UNIQUE constraint or PRIMARY KEY on (notificationId, userId)
-- in your NotificationUser table. If such a constraint does not exist,
-- duplicate entries might be created if run multiple times.
-- If you do not have a unique constraint, consider this alternative:
/*
INSERT INTO NotificationUser (notificationId, userId, markRead, archived, deleted, pushNotification)
SELECT
    1,
    u.userId,
    FALSE,
    FALSE,
    FALSE,
    FALSE
FROM
    User u
WHERE NOT EXISTS (
    SELECT 1
    FROM NotificationUser nu
    WHERE nu.userId = u.userId AND nu.notificationId = 1
);
*/
