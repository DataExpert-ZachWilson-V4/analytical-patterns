-- This query aims to determine the most games a single team has won in any given 90-game stretch.
-- 1. Identifying the winning games for each team.
-- 2. Assigning a sequential game number to each game for each team.
-- 3. Calculating a rolling sum of wins over the last 90 games for each team.
-- 4. Selecting the maximum number of wins in any 90-game stretch for each team and determining the highest value.

-- Identify the winning games for each team
WITH team_wins AS (
    SELECT
        ngd.team_id,                      -- Team ID
        ngd.team_abbreviation,            -- Team abbreviation
        ngd.game_id,                      -- Game ID
        ng.game_date_est,                 -- Game date
        CASE
            WHEN ng.home_team_id = ngd.team_id AND ng.home_team_wins = 1 THEN 1  -- Home team win
            WHEN ng.visitor_team_id = ngd.team_id AND ng.home_team_wins = 0 THEN 1  -- Visitor team win
            ELSE 0  -- No win
        END AS win                        -- Win flag
    FROM
        bootcamp.nba_game_details ngd
    JOIN
        bootcamp.nba_games ng ON ng.game_id = ngd.game_id  -- Join game details with game dates
    GROUP BY
        ngd.team_id, ngd.team_abbreviation, ngd.game_id, ng.game_date_est, ng.home_team_id, ng.visitor_team_id, ng.home_team_wins
),

-- Assign a sequential game number to each game for each team
team_games AS (
    SELECT
        team_id,                      
        team_abbreviation,             
        game_date_est,                    
        win,                              -- Win flag
        ROW_NUMBER() OVER (PARTITION BY team_id ORDER BY game_date_est) AS game_num  
    FROM
        team_wins
),

-- Calculate a rolling sum of wins over the last 90 games for each team
rolling_wins AS (
    SELECT
        team_id,                          
        team_abbreviation,                
        game_num,                        
        SUM(win) OVER (PARTITION BY team_id ORDER BY game_num ROWS BETWEEN 89 PRECEDING AND CURRENT ROW) AS wins_90_game  -- Rolling sum of wins
    FROM
        team_games
)

-- Select the maximum number of wins in any 90-game stretch for each team and determine the highest value
SELECT
    team_id,                              
    team_abbreviation,                    
    MAX(wins_90_game) AS max_wins_in_90_games  -- Maximum wins in a 90-game stretch
FROM
    rolling_wins
GROUP BY
    team_id, team_abbreviation            
ORDER BY
    max_wins_in_90_games DESC             
LIMIT 1                                   


