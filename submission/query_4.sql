-- Build additional queries on top of the results of the GROUPING SETS aggregations above to answer the following questions:
--     Write a query (query_4) to answer: "Which player scored the most points in one season?"

WITH
    ranked AS (
        SELECT
            player_name,
            season,
            total_player_points,
            DENSE_RANK() OVER(ORDER BY total_player_points DESC) AS rank
        FROM
            hariomnayani88482.game_details_dashboard
        WHERE
            player_name IS NOT NULL
        AND
            season IS NOT NULL
        AND
            total_player_points IS NOT NULL
)
SELECT
  player_name,
  season,
  total_player_points
FROM
  ranked
WHERE
  rank = 1