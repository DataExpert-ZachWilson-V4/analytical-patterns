WITH ranked_players AS (
    SELECT player,season,SUM(points) AS total_points,DENSE_RANK() OVER (ORDER BY SUM(points) DESC) AS rank
    FROM saidaggupati.grouping_sets
    WHERE player IS NOT NULL AND season IS NOT NULL
    GROUP BY player,season
)

SELECT player,season,total_points
FROM ranked_players
WHERE rank = 1