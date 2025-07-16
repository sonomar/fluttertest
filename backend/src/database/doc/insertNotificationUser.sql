-- This SQL script creates default notification user entries for all existing users.
-- It ensures that each user has a 'NotificationUser' entry linked to both
-- 'notificationId = 1' and 'notificationId = 2', but only if such an entry
-- does not already exist for that specific user and notification combination.
-- This is useful for backfilling data for existing users to match the logic
-- in the 'after_user_insert_create_first_notificationUser' trigger.

INSERT INTO NotificationUser (notificationId, userId, markRead, archived, deleted, pushNotification)
SELECT
    n.notificationId,    -- The notification ID to link (1 or 2)
    u.userId,            -- The ID of the existing user
    FALSE AS markRead,   -- Default: not read
    FALSE AS archived,   -- Default: not archived
    FALSE AS deleted,    -- Default: not deleted
    FALSE AS pushNotification -- Default: push notifications off
FROM
    User u
CROSS JOIN
    -- Creates a temporary table with the notification IDs we want to ensure exist for every user.
    (SELECT 1 AS notificationId UNION ALL SELECT 2) AS n
WHERE NOT EXISTS (
    -- This subquery checks if an entry for the specific user and notification ID
    -- already exists in the NotificationUser table. The INSERT will only happen
    -- for combinations that do not already exist.
    SELECT 1
    FROM NotificationUser nu
    WHERE nu.userId = u.userId AND nu.notificationId = n.notificationId
);
