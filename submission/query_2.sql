CREATE OR REPLACE TABLE saidaggupati.grouping_sets AS
WITH combined AS (
 SELECT player_name, COALESCE(team_city, 'NA') AS team_city, season, SUM(d.pts) AS points,  
    SUM(
        CASE
                WHEN (d.team_id = g.home_team_id AND home_team_wins = 1) OR
                     (d.team_id = g.visitor_team_id AND home_team_wins = 0) THEN 1
                ELSE 0
            END
        ) AS total_games_won  
    FROM bootcamp.nba_game_details_dedup AS d 
    JOIN bootcamp.nba_games AS g  
    ON d.game_id = g.game_id  
    GROUP BY
        GROUPING SETS (
            (player_name, team_city),  
            (player_name, season),  
            (team_city)  
        )
)

SELECT player_name AS player, team_city AS team, season, points, total_games_won 
FROM combined