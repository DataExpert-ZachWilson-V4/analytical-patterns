/*
Write a query (query_4) to answer: 
"Which player scored the most points in one season?"
*/

SELECT
    player_name,
    season,
    total_points
FROM danieldavid.nba_game_details_grouped
WHERE aggregation_level = 'player_and_season' AND total_points IS NOT NULL
ORDER BY total_points DESC
LIMIT 1