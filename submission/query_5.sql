SELECT
  team,
  total_wins
FROM
  ebrunt.game_details_dashboard
WHERE
  aggregation_level = 'team'
  AND total_wins = (
    SELECT
      MAX(total_wins)
    FROM
      ebrunt.game_details_dashboard
    WHERE
      aggregation_level = 'team'
  )

