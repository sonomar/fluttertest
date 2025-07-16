CREATE TRIGGER after_user_insert_create_first_notificationUser
AFTER INSERT ON `User`
FOR EACH ROW
BEGIN
    -- Link the initial notifications (ID 1 and 2) to the new user.
    -- This uses a single, efficient INSERT statement to add both records.
    INSERT INTO NotificationUser (notificationId, userId, markRead, archived, deleted, pushNotification)
    VALUES
        (1, NEW.userId, FALSE, FALSE, FALSE, FALSE),
        (2, NEW.userId, FALSE, FALSE, FALSE, FALSE);

END;