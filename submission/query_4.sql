SELECT
    player_name,
    season,
    points
FROM supreethkabbin.game_details_dashboard
WHERE aggregation_level = 'player_and_season' 
    AND points IS NOT NULL
ORDER BY 
    points DESC
LIMIT 1