with player_team as(
select player_name,team_abbreviation,sum(points) as points
from game_details_grouping
group by 1,2
)
select player_name
from player_team
where player_name is not null
order by points desc
limit 1
