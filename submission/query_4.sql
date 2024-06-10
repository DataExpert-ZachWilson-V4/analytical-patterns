with player_season as(
select player_name,season,sum(points) as points
from deeptianievarghese22866.game_details_grouping
group by 1,2
)
select player_name
from player_season
where player_name is not null
order by points desc
limit 1
