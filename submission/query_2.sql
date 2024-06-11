CREATE OR REPLACE TABLE lsleena.game_ag_details AS
WITH
  details AS (
    SELECT
     COALESCE(player_name, 'NA') AS player_name,
     COALESCE(team_city, 'NA') AS team,
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
    details