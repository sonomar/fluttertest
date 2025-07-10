CREATE TRIGGER after_user_collectible_insert_update_mission_progress
AFTER INSERT ON `UserCollectible`
FOR EACH ROW
BEGIN
    DECLARE mission_id_var INT;
    DECLARE mission_goal_var INT;
    DECLARE user_progress INT;
    DECLARE done INT DEFAULT FALSE;

    -- A cursor to find all missions that are affected by the newly collected item.
    -- It now filters for missions with missionTypeId = 1.
    DECLARE cur CURSOR FOR
        SELECT M.missionId, M.goal
        FROM Mission M
        WHERE 
            JSON_CONTAINS(M.parameterJson, CAST(NEW.collectibleId AS JSON), '$.collectibleIds')
            AND M.missionTypeId = 1;

    -- Handler to exit the loop when the cursor has no more rows
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO mission_id_var, mission_goal_var;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- If the user is not yet associated with the mission, create a new record for them.
        IF NOT EXISTS (SELECT 1 FROM MissionUser WHERE userId = NEW.ownerId AND missionId = mission_id_var) THEN
            INSERT INTO MissionUser (userId, missionId, progress, completed, rewardClaimed)
            VALUES (NEW.ownerId, mission_id_var, 0, FALSE, FALSE);
        END IF;

        -- Recalculate the user's total progress for the current mission.
        -- This counts all distinct collectibles the user owns that are part of this mission's requirements.
        SELECT COUNT(DISTINCT uc.collectibleId) INTO user_progress
        FROM UserCollectible uc
        WHERE uc.ownerId = NEW.ownerId AND uc.collectibleId IN (
            SELECT j.value
            FROM Mission m_inner
            CROSS JOIN JSON_TABLE(m_inner.parameterJson->'$.collectibleIds', '$[*]' COLUMNS (value INT PATH '$')) as j
            WHERE m_inner.missionId = mission_id_var
        );

        -- Update the MissionUser record with the new progress.
        -- This statement will only run if the mission is NOT already marked as completed.
        -- It will not change the 'completed' status.
        UPDATE MissionUser
        SET
            -- The LEAST() function ensures that the progress value does not exceed the mission's goal.
            progress = LEAST(user_progress, mission_goal_var)
        WHERE
            userId = NEW.ownerId
            AND missionId = mission_id_var
            AND completed = FALSE; -- This condition ensures we don't update already completed missions.

    END LOOP;

    CLOSE cur;
END;