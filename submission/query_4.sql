--Query to asnwer: Which player scored the most points in one season?
select
  player,
  season,
  total_points
from grisreyesrios.nba_game_details_aggregations
where grouping_type = 'player_season'
order by total_points desc