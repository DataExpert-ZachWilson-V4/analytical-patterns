SELECT
  player,
  season,
  total_points
FROM
  mposada.hw_5_q_2
WHERE 
  aggregation_level = 'player_name__season' AND
  total_points IS NOT NULL
ORDER BY 
  total_points DESC
LIMIT 1 -- kevin durant scored the most points in one season
