-- which team won the most games with window function
WITH
    ranked AS (
        SELECT
            team,
            total_games_won,
            DENSE_RANK() OVER(ORDER BY total_games_won DESC) AS rnk
        FROM
            lsleena.game_agg_details 
        WHERE
            team <> 'NA'
)
SELECT
  team,
  total_games_won,
  rnk
FROM
  ranked
WHERE
    rnk = 1