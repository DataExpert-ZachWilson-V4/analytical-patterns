/*

- Build additional queries on top of the results of the `GROUPING SETS` aggregations above to answer the following questions:
  - Write a query (`query_4`) to answer: "Which player scored the most points in one season?"

*/

Select
    player_name,
    season,
    points
FROM
    mymah592.nba_grouping_sets
-- Filtering results for records of a specific aggregation layer. Can Order by and select top or DENSE_RANK() and select top
-- Not using DENSE_RANK() because likely not using trino elsewhere...

WHERE
    Aggregation_level = 'player_and_season'
    and points IS NOT NULL

ORDER BY
    points DESC

Limit 1

--using order by to isolate answer and query with 1 row limit
--player_name	season	points
--Kevin Durant	2013	3265

