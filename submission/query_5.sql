-- Find the team that has
-- won the most games
WITH
    ranked AS (
        SELECT
            team,
            total_games_won,
            DENSE_RANK() OVER(ORDER BY total_games_won DESC) AS n_r
        FROM
            sundeep.grouping_sets
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