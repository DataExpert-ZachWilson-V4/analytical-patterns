select
  player,
  team,
  total_points
from dennisgera.nba_game_details_aggregated
where grouping_type = 'player_team'
order by total_points desc
