select
  team,
  wins
from dennisgera.nba_game_details_aggregated
where grouping_type = 'team'
order by wins desc
