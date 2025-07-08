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
        SELECT COUNT(DISTINCT collectibleId) INTO user_progress
        FROM UserCollectible
        WHERE ownerId = NEW.ownerId AND collectibleId IN (
            SELECT JSON_UNQUOTE(JSON_EXTRACT(j.value, '$'))
            FROM Mission
            CROSS JOIN JSON_TABLE(parameterJson->'$.collectibleIds', '$[*]' COLUMNS (value INT PATH '$')) as j
            WHERE Mission.missionId = mission_id_var
        );

        UPDATE MissionUser
        SET progress = user_progress,
            completed = IF(user_progress >= mission_goal_var, TRUE, FALSE)
        WHERE userId = NEW.ownerId AND missionId = mission_id_var;

    END LOOP;

    CLOSE cur;
END;