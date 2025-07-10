-- Step 1: Insert missing entries into MissionUser for relevant missions (type 1)
-- This query identifies users who have collectibles for a mission of type 1
-- but do not yet have an entry in the MissionUser table. It inserts these
-- missing entries with initial values.
INSERT INTO MissionUser (userId, missionId, progress, completed, rewardClaimed)
SELECT
    DISTINCT uc.ownerId,
    m.missionId,
    0,       -- Initial progress, to be updated in the next step
    FALSE,   -- Not completed initially
    FALSE    -- Reward not claimed initially
FROM
    UserCollectible uc
JOIN
    Mission m ON JSON_CONTAINS(m.parameterJson, CAST(uc.collectibleId AS JSON), '$.collectibleIds')
    AND m.missionTypeId = 1 -- Ensures we only consider missions of type 1
LEFT JOIN
    MissionUser mu ON mu.userId = uc.ownerId AND mu.missionId = m.missionId
WHERE
    mu.userId IS NULL; -- Only insert if no existing entry for this user-mission pair

-- Step 2: Recalculate and update progress for non-completed MissionUser entries (type 1)
-- This query updates the 'progress' for all relevant MissionUser records.
-- It does not change the 'completed' status.
UPDATE MissionUser mu
JOIN (
    -- Subquery to calculate the current progress for each user-mission pair of type 1.
    -- It counts the distinct collectibles a user owns that are required by the mission.
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
        AND JSON_CONTAINS(m_inner.parameterJson, CAST(uc_inner.collectibleId AS JSON), '$.collectibleIds')
    WHERE
        m_inner.missionTypeId = 1 -- Restrict calculation to missions of type 1
    GROUP BY
        mu_inner.userId, mu_inner.missionId, m_inner.goal
) AS calculated_progress ON mu.userId = calculated_progress.userId AND mu.missionId = calculated_progress.missionId
SET
    -- Update progress, ensuring it does not exceed the mission goal.
    mu.progress = LEAST(calculated_progress.current_progress, calculated_progress.mission_goal)
WHERE
    mu.completed = FALSE; -- Only update missions that are not already marked as complete.
