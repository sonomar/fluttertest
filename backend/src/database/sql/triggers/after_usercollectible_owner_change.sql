-- This script creates a stored procedure and a trigger to handle mission progress
-- updates when a collectible is transferred from one user to another.

-- Drop the existing procedure and trigger if they exist, to allow for recreation.
DROP PROCEDURE IF EXISTS UpdateUserMissionProgressForCollectible;
DROP TRIGGER IF EXISTS after_usercollectible_owner_change;

-- Change the delimiter to allow for semicolons within the procedure and trigger bodies.
DELIMITER $$

-- Step 1: Create a Stored Procedure to recalculate mission progress.
-- This procedure takes a userId and a collectibleId as input. It finds all missions
-- of type 1 related to that collectible and recalculates the specified user's progress.
CREATE PROCEDURE UpdateUserMissionProgressForCollectible(IN p_userId INT, IN p_collectibleId INT)
BEGIN
    DECLARE mission_id_var INT;
    DECLARE mission_goal_var INT;
    DECLARE user_progress INT;
    DECLARE done INT DEFAULT FALSE;

    -- A cursor to find all missions of type 1 that require the transferred collectible.
    DECLARE cur CURSOR FOR
        SELECT m.missionId, m.goal
        FROM Mission m
        WHERE m.missionTypeId = 1
          AND JSON_CONTAINS(m.parameterJson, CAST(p_collectibleId AS JSON), '$.collectibleIds');

    -- Handler to exit the loop when the cursor has no more rows.
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO mission_id_var, mission_goal_var;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Recalculate the user's progress for the current mission.
        -- This counts all distinct collectibles the user owns that are part of the mission's requirements.
        SELECT COUNT(DISTINCT uc.collectibleId) INTO user_progress
        FROM UserCollectible uc
        WHERE uc.ownerId = p_userId AND uc_inner.collectibleId IN (
            SELECT j.value
            FROM Mission m_inner
            CROSS JOIN JSON_TABLE(m_inner.parameterJson->'$.collectibleIds', '$[*]' COLUMNS (value INT PATH '$')) as j
            WHERE m_inner.missionId = mission_id_var
        );

        -- Update the MissionUser record for the specified user and mission.
        -- This update only affects non-completed missions and does not touch the 'completed' status.
        UPDATE MissionUser
        SET
            -- The LEAST() function ensures that progress does not exceed the mission's goal.
            progress = LEAST(user_progress, mission_goal_var)
        WHERE
            userId = p_userId
            AND missionId = mission_id_var
            AND completed = FALSE;

    END LOOP;

    CLOSE cur;
END$$

-- Step 2: Create the Trigger to monitor ownership changes.
-- This trigger fires after a UserCollectible is updated.
CREATE TRIGGER after_usercollectible_owner_change
AFTER UPDATE ON `UserCollectible`
FOR EACH ROW
BEGIN
    -- Check if the ownerId has changed and the previousOwnerId is not null.
    -- This indicates a transfer from one user to another.
    IF OLD.ownerId <> NEW.ownerId AND OLD.previousOwnerId IS NOT NULL THEN
        -- Recalculate progress for the previous owner (who lost the collectible).
        CALL UpdateUserMissionProgressForCollectible(OLD.ownerId, NEW.collectibleId);

        -- Recalculate progress for the new owner (who gained the collectible).
        CALL UpdateUserMissionProgressForCollectible(NEW.ownerId, NEW.collectibleId);
    END IF;
END$$

-- Reset the delimiter back to the default.
DELIMITER ;
