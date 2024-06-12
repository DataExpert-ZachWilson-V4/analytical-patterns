-- Which team has won the most games
-- If there is a tie, retunn multiple teams.

WITH ranked_team_scores AS (
    SELECT team_abbreviation,
        total_games_team_won,
        DENSE_RANK() OVER (ORDER BY total_games_team_won DESC) as rnk
    FROM ovoxo.nba_game_details_grouped
    WHERE agg_type = 'team_aggregate'
)

SELECT team_abbreviation,
    total_games_team_won
FROM ranked_team_scores
where rnk = 1