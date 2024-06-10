-- This query aims to determine the longest streak of consecutive games where LeBron James scored over 10 points.
-- 1. Deduplicating and joining game details with game dates for LeBron James.
-- 2. Creating a flag to indicate if he scored over 10 points in a game.
-- 3. Using the LAG function to compare the current game's score with the previous game's score.
-- 4. Identifying streaks by creating a streak identifier whenever the score flag changes.
-- 5. Calculating the length of each streak where he scored over 10 points.
-- 6. Selecting the maximum streak length from the calculated streaks.

-- Deduplicate the game details for LeBron James and join with game dates
WITH lebron_games AS (
    SELECT DISTINCT
        ng.game_date_est,  
        ngd.pts          
    FROM
        bootcamp.nba_game_details ngd
    JOIN
        bootcamp.nba_games ng ON ngd.game_id = ng.game_id  
    WHERE
        ngd.player_name = 'LeBron James' 
),

-- Create a flag to indicate if LeBron scored over 10 points
game_results AS (
    SELECT 
        game_date_est,                              
        CASE WHEN pts > 10 THEN 1 ELSE 0 END AS over_ten_points  -- Flag for scoring over 10 points
    FROM 
        lebron_games
),

-- Use LAG to get the previous game's over_ten_points value
lagged AS (
    SELECT 
        game_date_est,              
        over_ten_points,            -- Current game's over_ten_points flag
        LAG(over_ten_points, 1, 0) OVER (ORDER BY game_date_est) AS prev_over_ten_points  -- Previous game's over_ten_points flag
    FROM 
        game_results
),

-- Identify streaks where the over_ten_points value changes
streaks AS (
    SELECT 
        game_date_est,               
        over_ten_points,             -- Current game's over_ten_points flag
        CASE 
            WHEN over_ten_points != prev_over_ten_points THEN 1  -- New streak if current flag is different from previous
            ELSE 0 
        END AS new_streak,
        SUM(CASE 
            WHEN over_ten_points != prev_over_ten_points THEN 1  -- Summing up new streaks to create a streak identifier
            ELSE 0 
        END) OVER (ORDER BY game_date_est) AS streak_id
    FROM 
        lagged
),

-- Calculate the length of each streak where LeBron scored over 10 points
streak_lengths AS (
    SELECT 
        streak_id,                 
        COUNT(*) AS streak_length    -- Length of the streak
    FROM 
        streaks
    WHERE 
        over_ten_points = 1          -- Only consider streaks where LeBron scored over 10 points
    GROUP BY 
        streak_id
)

-- Select the maximum streak length
SELECT 
    MAX(streak_length) AS max_streak_length  -- The longest streak of games where LeBron scored over 10 points
FROM 
    streak_lengths







