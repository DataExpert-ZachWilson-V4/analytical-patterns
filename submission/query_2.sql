SELECT 
    COALESCE(player_name, 'overall') AS player,  -- Handle null player names when grouping by team
    COALESCE(team_abbreviation, 'overall') AS team,  -- Handle null team abbreviations when grouping by player and season
    COALESCE(CAST(season AS VARCHAR), 'overall') AS season,  -- Handle null seasons when grouping by player and team
    COUNT(game_id) AS total_games_played,  
    SUM(pts) AS total_points,  
    SUM(
        CASE WHEN (team_id = home_team_id AND home_team_wins = 1) OR (team_id = visitor_team_id AND home_team_wins = 0)
        THEN 1 ELSE 0 END
     ) AS total_wins 
FROM 
    bootcamp.nba_game_details
LEFT JOIN 
    bootcamp.nba_games USING(game_id)  -- Join game details with games
GROUP BY 
    GROUPING SETS (
        (player_name, team_abbreviation),  -- Group by player and team
        (player_name, season),  -- Group by player and season
        (team_abbreviation)  -- Group by team
    )
