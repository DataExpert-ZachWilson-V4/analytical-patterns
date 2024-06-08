WITH player_season_points AS (
    -- Selecting player name, team, and total points from the specified table
    SELECT
        player_name,
        team,
        total_player_points
    FROM
        raj.nba_games_grouping
    WHERE
        -- Filtering for rows representing a combination of a single player and a season,
        -- and where points are available
        Agg_Level = 'player_plus_season'
        AND total_player_points IS NOT NULL
)
-- Selecting the top-scoring record from the filtered results
SELECT
    player_name,
    team,
    total_player_points
FROM
    player_season_points
ORDER BY
    total_player_points DESC      -- Sorting the rows in descending order based on the points to bring the highest scorer to the top
LIMIT 1                           -- Return only the top scoring record
