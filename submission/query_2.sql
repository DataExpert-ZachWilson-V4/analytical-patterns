SELECT 
    COALESCE(player_name, 'overall') AS player,  -- Handle null player names when grouping by team
    COALESCE(team_abbreviation, 'overall') AS team,  -- Handle null team abbreviations when grouping by player and season
    COALESCE(CAST(season AS VARCHAR), 'overall') AS season,  -- Handle null seasons when grouping by player and team
    SUM(
        CASE 
            WHEN POSITION(':' IN min) > 0 THEN  
                (CAST(SUBSTRING(min, 1, POSITION(':' IN min) - 1) AS DOUBLE) * 60) +  
                CAST(SUBSTRING(min, POSITION(':' IN min) + 1) AS DOUBLE)  
            ELSE 
                CAST(min AS DOUBLE) * 60  -- Convert minutes to seconds
    END
    ) AS total_seconds_played,  -- Total seconds played
    COUNT(game_id) AS total_games_played,  -- Total games played
    SUM(fgm) AS total_field_goals_made,  -- Total field goals made
    SUM(fga) AS total_field_goals_attempted,  -- Total field goals attempted
    AVG(fg_pct) AS avg_field_goal_percentage,  -- Average field goal percentage
    SUM(fg3m) AS total_three_pointers_made,  -- Total three-pointers made
    SUM(fg3a) AS total_three_pointers_attempted,  -- Total three-pointers attempted
    AVG(fg3_pct) AS avg_three_point_percentage,  -- Average three-point percentage
    SUM(ftm) AS total_free_throws_made,  -- Total free throws made
    SUM(fta) AS total_free_throws_attempted,  -- Total free throws attempted
    AVG(ft_pct) AS avg_free_throw_percentage,  -- Average free throw percentage
    SUM(oreb) AS total_offensive_rebounds,  -- Total offensive rebounds
    SUM(dreb) AS total_defensive_rebounds,  -- Total defensive rebounds
    SUM(reb) AS total_rebounds,  -- Total rebounds
    SUM(ast) AS total_assists,  -- Total assists
    SUM(stl) AS total_steals,  -- Total steals
    SUM(blk) AS total_blocks,  -- Total blocks
    SUM(to) AS total_turnovers,  -- Total turnovers
    SUM(pf) AS total_personal_fouls,  -- Total personal fouls
    SUM(pts) AS total_points,  -- Total points
    SUM(plus_minus) AS total_plus_minus  -- Total plus/minus
FROM 
    bootcamp.nba_game_details
LEFT JOIN 
    bootcamp.nba_games USING(game_id)  -- Join game details with games
GROUP BY 
    GROUPING SETS (
        (player_name, team_abbreviation),  -- Group by player and team
        (player_name, season),  -- Group by player and season
        (team_abbreviation)  -- Group by team
    );
