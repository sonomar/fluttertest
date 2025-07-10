-- This trigger fires after a new user is created in the 'User' table.
-- Its purpose is to initialize the user's account with starting missions and a welcome notification.
CREATE TRIGGER after_user_insert_create_missionUser
AFTER INSERT ON `User` -- This trigger is attached to the 'User' table.
FOR EACH ROW
BEGIN
    -- Insert a MissionUser record for the new user for every existing mission.
    -- The progress is set based on the missionTypeId.
    INSERT INTO MissionUser (userId, missionId, progress, completed, rewardClaimed)
    SELECT
        NEW.userId,                                 -- The ID of the newly created user
        missionId,                              -- The ID of the mission from the Mission table
        CASE
            WHEN missionTypeId = 2 THEN 1        -- If missionTypeId is 2, set initial progress to 1
            ELSE 0                              -- Otherwise, set initial progress to 0
        END,
        FALSE,                                  -- Not completed initially
        FALSE                                   -- Reward not claimed initially
    FROM
        Mission;


END;
