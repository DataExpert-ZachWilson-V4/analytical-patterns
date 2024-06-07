SELECT
  team,
  total_wins
FROM
  mposada.hw_5_q_2
WHERE 
  aggregation_level = 'team_name' AND
  total_wins IS NOT NULL AND
  total_wins = (
    SELECT MAX(total_wins) -- we select max because this will bring in more than one team if theres a tie for first place
    FROM mposada.hw_5_q_2
    WHERE aggregation_level = 'team_name'
  )
ORDER BY 
  total_wins DESC -- the san antonio spurs have the most wins
