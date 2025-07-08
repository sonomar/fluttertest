CREATE TRIGGER after_user_collectible_insert_update_mission_progress
AFTER INSERT ON `UserCollectible`
FOR EACH ROW
BEGIN
    DECLARE mission_id_var INT;
    DECLARE mission_goal_var INT;
    DECLARE user_progress INT;
    DECLARE done INT DEFAULT FALSE;
    DECLARE cur CURSOR FOR
        SELECT M.missionId, M.goal
        FROM Mission M
        WHERE JSON_CONTAINS(M.parameterJson, CAST(NEW.collectibleId AS JSON), '$.collectibleIds');
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO mission_id_var, mission_goal_var;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Check if the user is in the mission, if not, add them
        IF NOT EXISTS (SELECT 1 FROM MissionUser WHERE userId = NEW.ownerId AND missionId = mission_id_var) THEN
            INSERT INTO MissionUser (userId, missionId, progress, completed, rewardClaimed)
            VALUES (NEW.ownerId, mission_id_var, 0, FALSE, FALSE);
        END IF;

        -- Update progress
        SELECT COUNT(DISTINCT uc.collectibleId) INTO user_progress
        FROM UserCollectible uc
        WHERE uc.ownerId = NEW.ownerId AND uc.collectibleId IN (
            SELECT j.value -- Corrected: j.value is already an INT, no need for JSON_EXTRACT or JSON_UNQUOTE
            FROM Mission m_inner
            CROSS JOIN JSON_TABLE(m_inner.parameterJson->'$.collectibleIds', '$[*]' COLUMNS (value INT PATH '$')) as j
            WHERE m_inner.missionId = mission_id_var
        );

        UPDATE MissionUser
        SET progress = user_progress,
            completed = IF(user_progress >= mission_goal_var, TRUE, FALSE)
        WHERE userId = NEW.ownerId AND missionId = mission_id_var;

    END LOOP;

    CLOSE cur;
END;