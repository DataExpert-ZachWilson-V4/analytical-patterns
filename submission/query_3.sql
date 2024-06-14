SELECT
  player,
  team,
  total_points
FROM
  ebrunt.game_details_dashboard
WHERE
  aggregation_level = 'player_team'
  AND total_points = (
    SELECT
      MAX(total_points)
    FROM
      ebrunt.game_details_dashboard
    WHERE
      aggregation_level = 'player_team'
  )
