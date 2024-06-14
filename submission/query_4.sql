SELECT
  player,
  season,
  total_points
FROM
  ebrunt.game_details_dashboard
WHERE
  aggregation_level = 'player_season'
  AND total_points = (
    SELECT
      MAX(total_points)
    FROM
      ebrunt.game_details_dashboard
    WHERE
      aggregation_level = 'player_season'
  )
