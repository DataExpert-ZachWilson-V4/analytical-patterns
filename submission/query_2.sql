CREATE OR REPLACE TABLE videet.nba_grouping_sets AS

SELECT 
    -- Determine the aggregation level based on the grouping context
    CASE 
        WHEN GROUPING(gd.player_name, gd.team_abbreviation) = 0 THEN 'player_plus_team'
        WHEN GROUPING(gd.player_name, g.season) = 0 THEN 'player_plus_season'
        WHEN GROUPING(gd.team_abbreviation) = 0 THEN 'team'
    END AS aggregation_level,
    
    -- Use COALESCE to handle NULL values, assigning 'Overall' where specific details are grouped out
    COALESCE(gd.player_name, 'Overall') AS player_name,
    COALESCE(gd.team_abbreviation, 'Overall') AS team,
    
    -- Aggregate the total points scored
    SUM(gd.pts) AS points,
    
    -- Use COALESCE to display 'Overall' for aggregated seasons
    COALESCE(CAST(g.season AS VARCHAR), 'Overall') AS season,
    
    -- Calculate wins based on home or visitor team winning conditions
    SUM(CASE 
        WHEN (gd.team_id = g.home_team_id AND g.home_team_wins = 1) 
             OR (gd.team_id = g.visitor_team_id AND g.home_team_wins = 0) THEN 1
        ELSE 0 
    END) AS wins
    
-- Specify the data source and join condition
FROM
    bootcamp.nba_game_details_dedup AS gd
    JOIN bootcamp.nba_games AS g ON gd.game_id = g.game_id

-- Group the data using grouping sets to create different slices of the data
GROUP BY GROUPING SETS (
    (gd.player_name, gd.team_abbreviation), -- Group by player and team
    (gd.player_name, g.season),             -- Group by player and season
    (gd.team_abbreviation)                  -- Group by team only
) 