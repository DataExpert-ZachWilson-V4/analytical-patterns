-- grouped the data and get necessary agg data, to calculate in the next CTE
WITH grouped_data AS(
    SELECT d.player_name,
        d.team_abbreviation,
        g.season,
        SUM(d.pts) as total_points
    FROM bootcamp.nba_game_details d
        JOIN bootcamp.nba_games g ON d.game_id = g.game_id
    GROUP BY GROUPING SETS(
            (d.player_name, d.team_abbreviation),
            (d.player_name, g.season),
            (d.team_abbreviation)
        )
)
-- Lebron James is scored the most for CLE team
SELECT player_name,
    team_abbreviation,
    total_points
FROM grouped_data
-- Filtered bad data for this calculation
WHERE season is NULL
    AND player_name IS NOT NULL
    AND team_abbreviation IS NOT NULL
-- Ordered by descending and get the first record.
ORDER BY total_points DESC
LIMIT 1