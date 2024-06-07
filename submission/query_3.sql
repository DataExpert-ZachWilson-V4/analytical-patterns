SELECT
  player,
  team,
  total_points
FROM
  mposada.hw_5_q_2
WHERE 
  aggregation_level = 'player_name__team_name' AND
  total_points IS NOT NULL
ORDER BY 
  total_points DESC
LIMIT 1
