-- Which team has won the most games
-- If there is a tie, retunn multiple teams.

WITH ranked_team_scores AS (
    SELECT team_abbreviation,
        DENSE_RANK() OVER (ORDER BY total_points DESC) as rnk
    FROM ovoxo.nba_game_details_grouped
    WHERE agg_type = 'team_aggregate'
)

SELECT team_abbreviation
FROM ranked_team_scores
where rnk = 1