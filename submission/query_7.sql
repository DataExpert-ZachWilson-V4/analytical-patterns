WITH nba_games_data AS (
  SELECT -- Data already in "player", "game" granularity.
         GD.game_id, 
         GD.player_name,
         GD.pts > 10 AS plus_10_pts, -- If player scored more than 10 points.
         G.game_date_est AS game_date
  FROM bootcamp.nba_game_details_dedup AS GD
  JOIN bootcamp.nba_games AS G ON G.game_id = GD.game_id
),
lagged AS (
  SELECT 
    *,
    LAG(plus_10_pts, 1) OVER (PARTITION BY player_name ORDER BY game_date ASC) AS plus_10_pts_last_game
    -- Lagged column to get if player scored more than 10 points in the last game.
  FROM nba_games_data
)
SELECT
  player_name,
  SUM(IF(plus_10_pts AND plus_10_pts_last_game,1,0)) AS plus_10_pts_row
  -- Count of games where player scored more than 10 points in a row.
FROM lagged
WHERE player_name = 'LeBron James'
-- Filter to get only LeBron James data.
GROUP BY 1