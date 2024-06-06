-- Find the player with the most
-- points earned in any season
WITH
    ranked AS (
        SELECT
            player_name,
            season,
            points,
            DENSE_RANK() OVER(ORDER BY points DESC) AS n_r
        FROM
            sundeep.grouping_sets
        WHERE
            player_name IS NOT NULL
        AND
            season IS NOT NULL
)
SELECT
  player_name,
  season,
  points
FROM
  ranked
WHERE
  n_r = 1