--Query to answer: Which player scored the most points playing for a single team?
select
  player,
  team,
  total_points
from grisreyesrios.nba_game_details_aggregations
where grouping_type = 'player_team'
order by total_points desc