-- The DELIMITER commands are important for MySQL clients, but the trigger body is what matters here.
-- This command ensures the trigger is always fresh on execution.
DROP TRIGGER IF EXISTS after_user_insert_create_first_notificationUser;

CREATE TRIGGER after_user_insert_create_first_notificationUser
AFTER INSERT ON `User`
FOR EACH ROW
BEGIN
    DECLARE new_notification_id BIGINT;

    new_notification_id = 1;

    -- Link the new notification to the new user
    INSERT INTO NotificationUser (notificationId, userId, markRead, archived, deleted, pushNotification)
    VALUES (new_notification_id, NEW.userId, FALSE, FALSE, FALSE, FALSE);

END;