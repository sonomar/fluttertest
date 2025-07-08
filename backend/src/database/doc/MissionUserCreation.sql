-- Step 1: Insert missing entries into MissionUser
-- This query identifies users who have collectibles relevant to a mission
-- but do not yet have an entry in the MissionUser table for that specific mission.
-- It inserts these missing entries with initial progress, setting 'completed' and
-- 'rewardClaimed' to FALSE.
INSERT INTO MissionUser (userId, missionId, progress, completed, rewardClaimed)
SELECT
    DISTINCT uc.ownerId,
    m.missionId,
    0,       -- Initial progress (will be updated in the next step)
    FALSE,   -- Not completed initially
    FALSE    -- Reward not claimed initially
FROM
    UserCollectible uc
JOIN
    Mission m ON JSON_CONTAINS(m.parameterJson, CAST(uc.collectibleId AS JSON), '$.collectibleIds')
LEFT JOIN
    MissionUser mu ON mu.userId = uc.ownerId AND mu.missionId = m.missionId
WHERE
    mu.userId IS NULL; -- Only insert if no existing entry for this user-mission pair

-- Step 2: Recalculate and update progress for all relevant MissionUser entries
-- This query updates the 'progress' and 'completed' status for all existing
-- and newly inserted MissionUser records. It calculates the distinct count of
-- collectibles a user owns that are part of a specific mission's goal,
-- and then updates the MissionUser table accordingly.
UPDATE MissionUser mu
JOIN (
    -- Subquery to calculate the current progress for each user-mission pair.
    -- It counts the distinct collectibles owned by a user that are listed
    -- in the mission's parameterJson->'$.collectibleIds'.
    SELECT
        mu_inner.userId,
        mu_inner.missionId,
        COUNT(DISTINCT uc_inner.collectibleId) AS current_progress,
        m_inner.goal AS mission_goal
    FROM
        MissionUser mu_inner
    JOIN
        Mission m_inner ON mu_inner.missionId = m_inner.missionId
    LEFT JOIN
        UserCollectible uc_inner ON uc_inner.ownerId = mu_inner.userId
        AND uc_inner.collectibleId IN (
            -- Extracts collectible IDs from the mission's JSON parameter.
            SELECT j.value
            FROM Mission m_json_inner
            CROSS JOIN JSON_TABLE(m_json_inner.parameterJson->'$.collectibleIds', '$[*]' COLUMNS (value INT PATH '$')) as j
            WHERE m_json_inner.missionId = mu_inner.missionId
        )
    GROUP BY
        mu_inner.userId, mu_inner.missionId, m_inner.goal
) AS calculated_progress ON mu.userId = calculated_progress.userId AND mu.missionId = calculated_progress.missionId
SET
    mu.progress = calculated_progress.current_progress,
    mu.completed = IF(calculated_progress.current_progress >= calculated_progress.mission_goal, TRUE, FALSE);
