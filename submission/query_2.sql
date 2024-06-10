create or replace table game_details_grouping as
with combined as(
select *
from bootcamp.nba_game_details d
inner join
bootcamp.nba_games g
on d.game_id=g.game_id
and d.team_id=g.home_team_id
)


select player_name, team_id as team_id, season, 
sum(pts) as points, sum(home_team_wins) as game_wins
from combined
group by grouping sets(
(player_name,team_id),
(player_name,season),
(team_id)
)
