-- Which player scored the most points in one season
-- If there is a tie, retunn multiple players. 

WITH ranked_player_season_scores AS (
    SELECT player_name, 
    season,
    DENSE_RANK() OVER (ORDER BY total_points DESC) as rnk
    FROM ovoxo.nba_game_details_grouped
    WHERE agg_type = 'player_season_aggregate'
        AND total_points IS NOT NULL -- ignore players with null points, they didn't play in that seaason
)

SELECT player_name, season
FROM ranked_player_season_scores
where rnk = 1