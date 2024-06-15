WITH ranked_players AS (
    SELECT
    player,team,SUM(points) AS total_points,DENSE_RANK() OVER (ORDER BY SUM(points) DESC) AS rank
    FROM saidaggupati.grouping_sets
    WHERE player IS NOT NULL AND team <> 'N/A'
    GROUP BY player,team
)

SELECT player,team,total_points
FROM ranked_players
WHERE rank = 1