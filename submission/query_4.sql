-- Create a temporary table of players, seasons, and total points, ranked by total points
WITH player_season_maxpoints AS
(
SELECT 
  *,
  Dense_Rank() OVER(ORDER BY total_points DESC) AS ranking
FROM hdamerla.nba_grouping_sets 
WHERE aggregation_level = 'Player_Season' AND total_points IS NOT NULL
)
-- Select the player and season with the highest total points
SELECT 
  player
  season,
  total_player_points
FROM player_season_maxpoints 
WHERE ranking = 1
