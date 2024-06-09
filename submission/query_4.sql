select
  player,
  season,
  total_points
from dennisgera.nba_game_details_aggregated
where grouping_type = 'player_season'
order by total_points desc
