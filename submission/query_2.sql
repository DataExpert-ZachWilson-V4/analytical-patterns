WITH deduplicated_game_details AS (
    SELECT
        game_id,
        team_id,
        player_name,
        team_abbreviation,
        pts,
        ROW_NUMBER() OVER (PARTITION BY game_id, team_id, player_id ORDER BY game_id) AS rn
    FROM 
        bootcamp.nba_game_details
),
deduplicated_nba_games AS (
    SELECT
        game_id,
        season,
        home_team_id,
        visitor_team_id,
        home_team_wins,
        ROW_NUMBER() OVER (PARTITION BY game_id ORDER BY game_id) AS rn
    FROM 
        bootcamp.nba_games
)
SELECT 
    COALESCE(dgd.player_name, 'overall') AS player,  -- Handle null player names when grouping by team
    COALESCE(dgd.team_abbreviation, 'overall') AS team,  -- Handle null team abbreviations when grouping by player and season
    COALESCE(CAST(dng.season AS VARCHAR), 'overall') AS season,  -- Handle null seasons when grouping by player and team
    COUNT(dgd.game_id) AS total_games_played,  
    SUM(dgd.pts) AS total_points,  
    SUM(
        CASE WHEN (dgd.team_id = dng.home_team_id AND dng.home_team_wins = 1) OR (dgd.team_id = dng.visitor_team_id AND dng.home_team_wins = 0)
        THEN 1 ELSE 0 END
     ) AS total_wins 
FROM 
    deduplicated_game_details dgd
LEFT JOIN 
    deduplicated_nba_games dng ON dgd.game_id = dng.game_id  -- Join deduplicated game details with deduplicated games
WHERE 
    dgd.rn = 1 AND dng.rn = 1  -- Only include the first row in each group
GROUP BY 
    GROUPING SETS (
        (dgd.player_name, dgd.team_abbreviation),  -- Group by player and team
        (dgd.player_name, dng.season),  -- Group by player and season
        (dgd.team_abbreviation)  -- Group by team
    )
