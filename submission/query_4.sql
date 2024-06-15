-- - Build additional queries on top of the results of the `GROUPING SETS` aggregations above to answer the following questions:
--   - Write a query (`query_4`) to answer: "Which player scored the most points in one season?"

-- player_name	season	max_points
-- Kevin Durant	2013	3265
--
select
    player_name,
    season,
    MAX(total_points) as max_points
from shabab.nba_grouping_sets where aggregation_level = 'player_season'
group by player_name, season
order by max_points desc
limit 1
