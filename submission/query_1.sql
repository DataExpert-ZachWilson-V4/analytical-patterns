-- Build a CTE of previous season
WITH last_season AS (
    SELECT * 
    FROM bootcamp.nba_players
    WHERE current_season = 1999
),
-- CTE for current season
current_season AS (
    SELECT * 
    FROM bootcamp.nba_players
    WHERE current_season = 2000
),
-- CTE for final result
result AS (
    SELECT
        coalesce(l.player_name, c.player_name) AS player_name,
        CASE
            -- Last season year column is empty + current season is not and seasons cummulative array is empty
            WHEN l.current_season IS NULL and c.current_season IS NOT NULL and l.seasons IS NULL THEN 'New'
            -- Last season year is not empty + current season is not empty
            WHEN l.current_season IS NOT NULL and c.current_season IS NULL THEN 'Retired'
            -- Last season year is not empty + current season is not empty
            WHEN l.current_season IS NOT NULL and c.current_season IS NOT NULL THEN 'Continued Playing'
            -- Last season year is empty + current season year is not + seasons cumulative array is not empty
            WHEN l.current_season IS NULL and c.current_season IS NOT NULL and l.seasons IS NOT NULL THEN 'Returned FROM Retirement'
            ELSE 'Stayed Retired'
        END AS change_tracking,
        c.current_season
    FROM last_season l
    FULL OUTER JOIN current_season c
        ON c.player_name = l.player_name
)
SELECT 
    *
FROM result
