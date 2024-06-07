SELECT
  player,
  season,
  total_points
FROM
  mposada.hw_5_q_2
WHERE 
  aggregation_level = 'player_name__season' AND
  total_points IS NOT NULL AND
  total_points = (
    SELECT MAX(total_points) -- we select max because this will bring in more than one player if theres a tie for first place
    FROM mposada.hw_5_q_2
    WHERE aggregation_level = 'player_name__season'
  )
ORDER BY 
  total_points DESC-- kevin durant scored the most points in one season
