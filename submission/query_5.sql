/*

- Build additional queries on top of the results of the `GROUPING SETS` aggregations above to answer the following questions:
  - Write a query (`query_5`) to answer: "Which team has won the most games"

  */
  
Select
    team,
    games_won
FROM
    mymah592.nba_grouping_sets
-- Filtering results for records of a specific aggregation layer. Can Order by and select top or DENSE_RANK() and select top
-- Not using DENSE_RANK() because likely not using trino elsewhere...

WHERE
    Aggregation_level = 'team'
    and games_won IS NOT NULL

ORDER BY
    games_won DESC

Limit 1

--using order by to isolate answer and query with 1 row limit
--team	            games_won
--San Antonio Spurs	6267

