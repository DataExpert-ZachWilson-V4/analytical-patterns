with team_games as(
select team_abbreviation,sum(game_wins) as game_wins
from game_details_grouping
group by 1
)
select team_abbreviation
from team_games
where team_id is not null
order by game_wins desc
limit 1
