-- Build additional queries on top of the results of the GROUPING SETS aggregations above to answer the following questions:

--     Write a query (query_5) to answer: "Which team has won the most games"

WITH
    ranked AS (
        SELECT
            team,
            total_games_won,
            DENSE_RANK() OVER(ORDER BY total_games_won DESC) AS n_r
        FROM
            hariomnayani88482.game_details_dashboard
        WHERE
            team <> 'N/A'
)
SELECT
  team,
  total_games_won,
  n_r
FROM
  ranked
WHERE
    n_r = 1