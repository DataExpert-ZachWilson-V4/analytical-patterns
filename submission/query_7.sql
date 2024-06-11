WITH lebron_game_details
     AS (SELECT game_id,
                player_name,
                team_id,
                team_abbreviation,
                Sum(pts) AS total_points
         FROM   bootcamp.nba_game_details
         WHERE  player_name = 'LeBron James'
         GROUP  BY game_id,
                   team_id,
                   team_abbreviation,
                   player_name),
     combined
     AS (SELECT gd.game_id,
                gd.player_name,
                g.game_date_est,
                total_points,
                CASE
                  WHEN total_points > 10 THEN 1
                  ELSE 0
                END AS over_10_points
         FROM   bootcamp.nba_games g
                JOIN lebron_game_details gd
                  ON g.game_id = gd.game_id),
     lagged
     AS (SELECT game_id,
                player_name,
                game_date_est,
                total_points,
                over_10_points,
                Lag(over_10_points)
                  OVER (
                    ORDER BY game_date_est) AS over10_lagged
         FROM   combined),
     streaked
     AS (SELECT *,
                Sum(CASE
                      WHEN over10_lagged != over_10_points THEN 1
                      ELSE 0
                    END)
                  OVER (
                    ORDER BY game_date_est) AS streak_id
         FROM   lagged),
     streak_length
     AS (SELECT player_name,
                Count(1) AS streak_length
         FROM   streaked
         GROUP  BY player_name,
                   streak_id
         HAVING Max(over_10_points) = 1)
SELECT player_name,
       Max(streak_length) AS num_games_over_10
FROM   streak_length
GROUP  BY player_name  -- 261