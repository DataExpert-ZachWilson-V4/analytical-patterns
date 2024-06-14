WITH player_season_maxpoints AS
(
SELECT 
  *,
  Dense_Rank() OVER(ORDER BY total_points DESC) AS ranking
FROM hdamerla.nba_grouping_sets WHERE aggregation_level = 'Player_Season'
)
SELECT 
  player,
  season,
  total_points
FROM player_season_maxpoints WHERE ranking = 1
