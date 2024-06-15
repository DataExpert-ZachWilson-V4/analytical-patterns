WITH
    ranked_teams AS (
    SELECT team,total_games_won,DENSE_RANK() OVER(ORDER BY total_games_won DESC) AS rank
    FROM saidaggupati.grouping_sets
    WHERE team <> 'N/A'
)
SELECT team,total_games_won
FROM ranked_teams
WHERE rank = 1