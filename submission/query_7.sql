 --   use a window functions on nba_game_details to answer 
 --   the question: How many games in a row did 
 --   LeBron James score over 10 points a game?
WITH nba_games_data AS (
  SELECT 
        -- Data already in "player", "game" granularity.
         gd.game_id, 
         gd.player_name,
         gd.pts > 10 AS plus_10_pts, -- If player scored more than 10 points.
         g.game_date_est AS game_date
  FROM bootcamp.nba_game_details_dedup AS gd
  JOIN bootcamp.nba_games AS g ON g.game_id = gd.game_id
),
lagged AS (
  SELECT 
    *,
    -- lagged column to get player scored more than 
    -- 10 pts in the last game
    LAG(plus_10_pts, 1) OVER (PARTITION BY player_name 
        ORDER BY game_date ASC) AS plus_10_pts_last_game
    -- Lagged column to get if player scored more than 10 points in the last game.
  FROM nba_games_data
)
SELECT
  player_name,
  -- count of games player scored more than 10 pts
  SUM(IF(plus_10_pts AND plus_10_pts_last_game,1,0)) AS plus_10_pts_row
FROM lagged
-- filter for Lebron James
WHERE player_name = 'LeBron James'
GROUP BY player_name