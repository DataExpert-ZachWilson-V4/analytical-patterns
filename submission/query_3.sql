WITH player_team_points AS (
    -- Selecting player name, team, and total points from the specified table
    SELECT
        player_name,
        team,
        total_player_points
    FROM
        raj.nba_games_grouping
    WHERE
        -- Filtering for rows representing a combination of a single player and a single team,
        -- and where points are available
        Agg_Level = 'player_plus_team'
        AND total_player_points IS NOT NULL
)
-- Selecting the top-scoring record from the filtered results
SELECT
    player_name,
    team,
    total_player_points
FROM
    player_team_points
ORDER BY
    -- Sorting the rows in descending order based on the points to bring the highest scorer to the top
    total_player_points DESC
LIMIT 1 
