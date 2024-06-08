-- Which player scored the most points in one season
-- If there is a tie, retunn multiple players. 

WITH ranked_player_season_scores AS (
    SELECT player_name, 
    team_abbreviation,
    DENSE_RANK() OVER (ORDER BY total_points DESC) as rnk
    FROM ovoxo.nba_game_details_grouped
    WHERE agg_type = 'player_season_aggregate'
)

SELECT player_name
FROM ranked_player_season_scores
where rnk = 1