select player_name,season,points
from game_details_grouping
where aggregation_level='player_name__season' and points is not null
order by points desc
limit 1



