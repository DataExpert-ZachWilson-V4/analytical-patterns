WITH player_team_maxpoints AS
(
SELECT 
 *,
  Dense_Rank() OVER(ORDER BY total_points DESC) AS rnk 
FROM hdamerla.nba_grouping_sets WHERE aggregation_level = 'Player_Team'
)
SELECT 
  player,
  Team,
  total_points
FROM player_team_maxpoints WHERE rnk = 1
