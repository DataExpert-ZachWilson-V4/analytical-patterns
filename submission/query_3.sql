---- query_3: Create a CTE that ranks players by total points scored for a team

WITH player_team_maxpoints AS
(
SELECT 
 *,
  -- Rank players by total points in descending order
  Dense_Rank() OVER(ORDER BY total_points DESC) AS rnk 
FROM hdamerla.nba_grouping_sets WHERE aggregation_level = 'Player_Team'
  AND total_points IS NOT NULL
)
-- Select the player with the highest rank (i.e., the most points)
SELECT 
  player,
  Team,
  total_points
FROM player_team_maxpoints WHERE rnk = 1
