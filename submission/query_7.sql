-- How many games in a row did LeBron James score over 10 points a game?
-- games ordered by game_date_est
-- games where pts is NULL is breaking the streak, NULL likely indicates that LeBron James did not play, and therefore it would not make sense to include those games in the streak count.
-- streak is calculated based on the partitioning condition CASE WHEN pts > 10 THEN 1 ELSE 0 END

WITH 
    -- add a row number to each row in nba_game_details to be used for deduping
    nba_game_details_deduped AS (
        SELECT 
            *,
            ROW_NUMBER() OVER (PARTITION BY game_id, team_id, player_id) rn 
        FROM bootcamp.nba_game_details
    ),

    -- determine if player scored 10 points in a row
    combined AS (
        SELECT
            gd.player_name,
            gd.game_id,
            g.game_date_est,
            CASE 
              WHEN gd.pts > 10 THEN 1 
              ELSE 0
            END AS scored_10_pts
        FROM bootcamp.nba_games g 
        JOIN nba_game_details_deduped gd ON g.game_id = gd.game_id AND gd.rn = 1
    ),
    
    -- find lagged 10_point which would be used to determine streak
    lagged AS (
      SELECT *,
        LAG(scored_10_pts, 1, 0) OVER (PARTITION BY player_name ORDER BY game_date_est) AS lagged_streak
      FROM combined
    ),
  
  streaks AS (
    SELECT *,
        SUM(CASE 
                WHEN scored_10_pts = 1 and lagged_streak = 1 THEN 0 -- if a player scores 10 points and the previous game was also 10 points, then the streak continue and the ientifier doesn't change
                WHEN scored_10_pts = 1 and lagged_streak = 0 THEN 0 -- if a player scores 10 points and the previous game was not 10 points, then the streak is broken
                ELSE 1 
            END) OVER (PARTITION BY player_name ORDER BY game_date_est) AS streak_identifier
    FROM lagged
  )
  
SELECT player_name, 
    COUNT(1) AS consective_games_over_10_pts -- count number of games in a streak where player scored over 10 pts
FROM streaks
WHERE scored_10_pts = 1
  AND player_name = 'LeBron James'
GROUP BY player_name, streak_identifier
ORDER BY COUNT(1) DESC
LIMIT 1
