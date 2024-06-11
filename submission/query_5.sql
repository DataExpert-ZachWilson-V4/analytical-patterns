with team_wins_summary as(
select team_abbreviation,sum(game_wins) as game_wins
from deeptianievarghese22866.game_details_grouping
where aggregation_level = 'player_name__team_name'
group by 1
)
select team_abbreviation
from team_games
where game_wins=(select max(game_wins) from team_wins_summary)
