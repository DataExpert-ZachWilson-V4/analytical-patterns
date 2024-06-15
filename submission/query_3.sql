-- - Build additional queries on top of the results of the `GROUPING SETS` aggregations above to answer the following questions:
--   - Write a query (`query_3`) to answer: "Which player scored the most points playing for a single team?"

-- player_name	team_abbreviation	max_points
-- LeBron James	CLE	28314
--
select
    player_name,
    team_abbreviation,
    MAX(total_points) as max_points
from shabab.nba_grouping_sets where aggregation_level = 'player_team'
group by player_name, team_abbreviation
order by max_points desc
limit 1
