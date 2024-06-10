WITH individual_team_scoring AS (
  SELECT player, team, total_points, dense_rank() over (order by total_points desc) as rank
  FROM ebrunt.game_details_dashboard
  WHERE season = 'overall' AND player <> 'overall'
)
SELECT * FROM individual_team_scoring WHERE rank = 1
