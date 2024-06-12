-- "Which player scored the most points playing for a single team?"
-- If there is a tie, retunn multiple players. 

WITH ranked_player_team_scores AS (
    SELECT player_name, 
        team_abbreviation,
        total_points,
        DENSE_RANK() OVER (ORDER BY total_points DESC) as rnk
    FROM ovoxo.nba_game_details_grouped
    WHERE agg_type = 'player_team_aggregate'
        AND total_points IS NOT NULL -- ignore players with null points, this shouldn't impact the results
)

SELECT player_name, 
    team_abbreviation,
    total_points
FROM ranked_player_team_scores
WHERE rnk = 1
