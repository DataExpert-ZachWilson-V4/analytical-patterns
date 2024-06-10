-- How many games in a row did LeBron James score over 10 points a game?
WITH nba_games_data AS (
  SELECT 
         gd.game_id, 
         gd.player_name,
         gd.pts > 10 AS more_than_10_pts, -- Player scored more than 10 points -- BOOLean
         g.game_date_est AS game_date
  FROM bootcamp.nba_game_details_dedup AS gd
  JOIN bootcamp.nba_games AS g 
  ON g.game_id = gd.game_id
),
lagged AS (
  SELECT 
    *,
    -- Use the LAG function to generate previous game's `more_than_10_pts_last_game` for the player ordered by game date
    -- 10 pts in the last game
    LAG(more_than_10_pts, 1) OVER (PARTITION BY player_name ORDER BY game_date ASC) AS more_than_10_pts_last_game
  FROM nba_games_data
)
SELECT
  player_name,
  -- count of games player scored more than 10 pts
  SUM(CASE WHEN(more_than_10_pts AND more_than_10_pts_last_game) THEN 1 ELSE 0 END) AS more_than_10_pts_row
FROM lagged
-- filter for Lebron James
WHERE player_name = 'LeBron James'
GROUP BY player_name