-- Build additional queries on top of the results of the GROUPING SETS aggregations above to answer the following questions:

--     Write a query (query_3) to answer: "Which player scored the most points playing for a single team?"

WITH
    ranked AS (
        SELECT
            player_name,
            team,
            total_player_points,
            DENSE_RANK() OVER(ORDER BY total_player_points DESC) AS n_r
        FROM
            hariomnayani88482.game_details_dashboard
        WHERE
            team <> 'N/A'
        AND
            player_name IS NOT NULL
)
SELECT
  player_name,
  team,
  total_player_points
FROM
  ranked
WHERE
  n_r = 1 

