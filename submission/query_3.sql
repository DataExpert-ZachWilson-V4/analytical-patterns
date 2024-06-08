-- "Which player scored the most points playing for a single team?"
-- If there is a tie, retunn multiple players. 
-- We can also break the tie by an additional field in the order by but we will skip this for now.

WITH ranked_player_team_scores AS (
    SELECT player_name, 
    team_abbreviation,
    DENSE_RANK() OVER (ORDER BY total_points DESC) as rnk
    FROM ovoxo.nba_game_details_grouped
    WHERE agg_type = 'player_team_aggregate'
)

SELECT player_name
FROM ranked_player_team_scores
WHERE rnk = 1