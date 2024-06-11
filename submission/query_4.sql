with player_season as(
select player_name,season,sum(points) as points
from game_details_grouping
where aggregation_level='player_name__season'
group by 1,2
)
select player_name
from player_season
where points=(select max(points) from player_season)

