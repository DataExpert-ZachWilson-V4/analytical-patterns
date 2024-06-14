--Query to answer: "Which team has won the most games"
select
team, 
wins
from grisreyesrios.nba_game_details_aggregations
where grouping_type = 'team'
order by wins desc