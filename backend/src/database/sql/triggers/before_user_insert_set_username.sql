CREATE TRIGGER before_user_insert_set_username
BEFORE INSERT ON `User`
FOR EACH ROW
BEGIN
    -- If the username is not set, set it to a default format.
    IF NEW.username IS NULL THEN
        SET NEW.username = CONCAT('deins_user_', UUID());
    END IF;
END;