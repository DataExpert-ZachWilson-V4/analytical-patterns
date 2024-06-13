CREATE OR REPLACE TABLE game_details_grouping AS
WITH game_details_combined AS (
    SELECT *, ROW_NUMBER() OVER(PARTITION BY d.game_id, d.team_id, player_id ORDER BY g.game_date_est) AS row_num
    FROM bootcamp.nba_game_details d
    INNER JOIN bootcamp.nba_games g
    ON d.game_id = g.game_id
    AND d.team_id = g.home_team_id
   
)

SELECT
    CASE 
        WHEN GROUPING(player_name, team_abbreviation) = 0 THEN 'player_name__team_name'
        WHEN GROUPING(player_name, season) = 0 THEN 'player_name__season'
        WHEN GROUPING(team_abbreviation) = 0 THEN 'team_name'
    END as aggregation_level,
    player_name, 
    team_abbreviation, 
    season, 
    SUM(pts) AS points, 
    SUM(home_team_wins) AS game_wins
FROM game_details_combined
-- Filter out duplicates
WHERE row_num = 1
GROUP BY GROUPING SETS (
    (player_name, team_abbreviation),
    (player_name, season),
    (team_abbreviation)
)
