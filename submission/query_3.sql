--Which player scored the most points playing for a single team
select team,
player_name, points
from vaishnaviaienampudi83291.nba_grouping_data_sets
where agg_data = 'player_and_team'
and points > 0 
order by points desc 
limit 1