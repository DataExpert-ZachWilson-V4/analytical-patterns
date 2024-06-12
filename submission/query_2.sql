CREATE OR REPLACE TABLE supreethkabbin.game_details_dashboard AS
-- CTE to record deduped nba game details data
WITH game_details_combined AS (
    SELECT 
        *, 
        CASE 
            WHEN visitor_team_id = d.team_id AND home_team_wins = 1 THEN 0
            WHEN visitor_team_id = d.team_id AND home_team_wins = 0 THEN 1
            ELSE g.home_team_wins
        END AS won,
        ROW_NUMBER() OVER(PARTITION BY d.game_id, d.team_id, player_id ORDER BY g.game_date_est) AS row_num
    FROM bootcamp.nba_game_details d
    INNER JOIN bootcamp.nba_games g
        ON d.game_id = g.game_id
        AND d.team_id = g.home_team_id
)
-- Select with grouping sets for different levels of aggregation 
SELECT
    CASE 
        WHEN GROUPING(player_name, team_abbreviation) = 0 THEN 'player_and_team'
        WHEN GROUPING(player_name, season) = 0 THEN 'player_and_season'
        WHEN GROUPING(team_abbreviation) = 0 THEN 'team'
    END as aggregation_level,
    COALESCE(player_name, 'overall') as player_name,
    COALESCE(team_abbreviation, 'overall') as team_abbreviation,
    COALESCE(CAST(season AS VARCHAR), 'overall') as season,
    SUM(pts) AS points, 
    SUM(won) AS game_wins
FROM game_details_combined
WHERE row_num = 1
GROUP BY GROUPING SETS (
    (player_name, team_abbreviation),
    (player_name, season),
    (team_abbreviation)
)