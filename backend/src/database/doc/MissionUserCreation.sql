-- This script assigns all existing missions to all existing users if they are not already assigned.
-- It's designed to be run once to backfill data.

-- It uses a CROSS JOIN to create every possible combination of a user and a mission.
-- It then filters out the combinations that already exist in the MissionUser table.
INSERT INTO MissionUser (userId, missionId, progress, completed, rewardClaimed)
SELECT
    U.userId,                                   -- The ID of an existing user
    M.missionId,                            -- The ID of an existing mission
    CASE
        WHEN M.missionTypeId = 2 THEN 1      -- If missionTypeId is 2, set initial progress to 1
        ELSE 0                              -- Otherwise, set initial progress to 0
    END,
    FALSE,                                  -- Not completed initially
    FALSE                                   -- Reward not claimed initially
FROM
    `User` U
CROSS JOIN
    `Mission` M
LEFT JOIN
    `MissionUser` MU ON U.userId = MU.userId AND M.missionId = MU.missionId
WHERE
    MU.userId IS NULL; -- This condition ensures we only insert records for user-mission pairs that do not already exist.
