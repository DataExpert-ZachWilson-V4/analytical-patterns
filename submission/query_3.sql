with player_team as(
select player_name, team_abbreviation,sum(points) as points
from game_details_grouping
where aggregation_level = 'player_name__team_name'
group by 1,2
)
select player_name
from player_team
where points=(select max(points) from player_team)
