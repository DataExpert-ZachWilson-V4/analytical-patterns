-- - Build additional queries on top of the results of the `GROUPING SETS` aggregations above to answer the following questions:
--   - Write a query (`query_5`) to answer: "Which team has won the most games"

-- team_abbreviation	max_wins
-- SAS	                1182
--
select
    team_abbreviation,
    MAX(team_wins) as max_wins
from shabab.nba_grouping_sets where aggregation_level = 'team'
group by team_abbreviation
order by max_wins desc
limit 1

