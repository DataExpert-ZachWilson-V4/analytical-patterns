SELECT
  player,
  team,
  total_points
FROM
  mposada.hw_5_q_2
WHERE 
  aggregation_level = 'player_name__team_name' AND
  total_points IS NOT NULL AND
  total_points = (
    SELECT MAX(total_points) -- we select max because this will bring in more than one player if theres a tie for first place
    FROM mposada.hw_5_q_2
    WHERE aggregation_level = 'player_name__team_name'
  )
ORDER BY 
  total_points DESC -- answer is LeBron James for cleveland
