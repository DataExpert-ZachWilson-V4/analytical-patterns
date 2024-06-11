select player_name,season,sum(points) as points
from game_details_grouping
where aggregation_level='player_name__season'
group by 1,2
order by points desc
limit 1



