SELECT
  *
FROM
  mposada.hw_5_q_2
where aggregation_level = 'player_name__team_name'
order by total_points desc
limit 1  -- LeBron James with Cleveland
