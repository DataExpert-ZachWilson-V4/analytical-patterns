--player scored the most points in one season
select season,
player_name,
points
from vaishnaviaienampudi83291.nba_grouping_data_sets 
where agg_data = 'player_and_season'
and points > 0 
order by points desc 
limit 1