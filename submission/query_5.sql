-- Which team has won the most games
-- If there is a tie, retunn multiple teams.

WITH ranked_team_scores AS (
    SELECT team_abbreviation,
        DENSE_RANK() OVER (ORDER BY total_field_goals_made DESC) as rnk
    FROM ovoxo.nba_game_details_grouped
    WHERE team_abbreviation != '(all_teams)'
      AND player_name = '(all_players)'
)

SELECT team_abbreviation
FROM ranked_team_scores
where rnk = 1