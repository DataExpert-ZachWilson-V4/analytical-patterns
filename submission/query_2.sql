-- Write a query (query_2) that uses GROUPING SETS to perform aggregations of the nba_game_details data. Create slices that aggregate along the following combinations of dimensions:

--     player and team
--     player and season
--     team

--Creating base table for next 3 queries
CREATE OR REPLACE TABLE hariomnayani88482.game_details_dashboard AS
WITH
  combined AS (
    SELECT 
     player_name AS player_name,
     COALESCE(team_city, 'N/A') AS team,
     season,
     SUM(a.pts) AS total_player_points,
     SUM(CASE
            WHEN (a.team_id = b.home_team_id AND home_team_wins = 1) OR
             (a.team_id = b.visitor_team_id AND home_team_wins = 0) THEN 1
             ELSE 0 END
     ) AS total_games_won
    FROM 
        bootcamp.nba_game_details_dedup AS a 
    JOIN
        bootcamp.nba_games AS b 
    ON 
        a.game_id = b.game_id
    GROUP BY
     GROUPING SETS(
       (player_name, team_city),
       (player_name, season),
       (team_city)
     )
)
SELECT
    *
FROM
    combined