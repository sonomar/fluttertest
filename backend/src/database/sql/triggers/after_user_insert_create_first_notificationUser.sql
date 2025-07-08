CREATE TRIGGER after_user_insert_create_first_notificationUser
AFTER INSERT ON `User`
FOR EACH ROW
BEGIN
    DECLARE new_notification_id BIGINT;

    -- Set the notification ID (you may generate this dynamically if needed)
    SET new_notification_id = 1;

    -- Link the new notification to the new user
    INSERT INTO NotificationUser (notificationId, userId, markRead, archived, deleted, pushNotification)
    VALUES (new_notification_id, NEW.userId, FALSE, FALSE, FALSE, FALSE);

END;