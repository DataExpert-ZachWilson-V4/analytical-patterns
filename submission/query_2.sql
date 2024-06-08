-- Create or replace a table called 'nba_grouping_sets' in the 'videet' schema
CREATE OR REPLACE TABLE videet.nba_grouping_sets AS

WITH deduped AS (
    -- Select game details and use a window function to deduplicate records,
    -- assigning a unique row number for each player within each game and team combination
    SELECT 	
        g.game_date_est,
        g.season,
        gd.team_abbreviation as team_name,
        -- Determine win or loss for the team related to each player
        CASE 
            WHEN visitor_team_id = gd.team_id AND home_team_wins = 1 THEN 0
            WHEN visitor_team_id = gd.team_id AND home_team_wins = 0 THEN 1
            ELSE g.home_team_wins
        END AS won,
        gd.*,
        ROW_NUMBER() OVER(PARTITION BY gd.game_id, gd.team_id, player_id ORDER BY g.game_date_est) AS row_num
    FROM bootcamp.nba_game_details gd 
    JOIN bootcamp.nba_games g ON gd.game_id = g.game_id
)

SELECT 
    -- Categorize aggregation levels based on the presence of player and team or season in the group
    CASE 
        WHEN GROUPING(player_name, team_name) = 0 THEN 'player_plus_team'
        WHEN GROUPING(player_name, season) = 0 THEN 'player_plus_season'
        WHEN GROUPING(team_name) = 0 THEN 'team'
    END AS aggregation_level,
    -- Coalesce to replace any null names or team names with 'Overall'
    COALESCE(player_name, 'Overall') AS player_name,
    COALESCE(team_name, 'Overall') AS team,
    -- Sum up points for each group
    SUM(pts) AS points,
    -- Use cast to convert season to a string, replacing nulls with 'Overall'
    COALESCE(CAST(season AS VARCHAR), 'Overall') AS season,
    -- Sum up wins for each group
    SUM(won) AS wins
FROM deduped
-- Only include rows where the player's record for each game is unique
WHERE row_num = 1
-- Group the results by different sets to analyze data from multiple perspectives
GROUP BY GROUPING SETS (
    (player_name, team_name),
    (player_name, season),
    (team_name)
)
