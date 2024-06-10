--team has won the most games
select team,
wins
from vaishnaviaienampudi83291.nba_grouping_data_sets
where 
agg_data = 'team'
and wins > 0 
order by wins desc 
limit 1