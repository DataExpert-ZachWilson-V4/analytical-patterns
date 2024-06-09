-- Use DENSE_RANK to rank players based on points scored in one season
WITH ranked_players AS (
    SELECT
        player,
        season,
        SUM(points) AS total_points,
        DENSE_RANK() OVER (ORDER BY SUM(points) DESC) AS rank
    FROM
        sasiram410.grouping_sets
    WHERE
        player IS NOT NULL AND season IS NOT NULL
    GROUP BY
        player,
        season
)

-- Select the player(s) with the highest total points in any single season
SELECT
    player,
    season,
    total_points
FROM
    ranked_players
WHERE
    rank = 1
