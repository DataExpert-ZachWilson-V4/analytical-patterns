select player_name,season,points
from game_details_grouping
where aggregation_level='player_name__season'
order by points desc
limit 1



