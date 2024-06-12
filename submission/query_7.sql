-- Query 7: How many games in a row did LeBron James score over 10 points a game?
-- CTE to select LeBron James' games and determine if he scored over 10 points
WITH lebron_games AS (
  SELECT 
    player_name,          -- Player name
    game_id,              -- Game ID
    pts,                  -- Points scored in the game
    CASE
      WHEN pts > 10 THEN 1  -- 1 if points scored are over 10, otherwise 0
      ELSE 0
    END AS over_10_pts
  FROM bootcamp.nba_game_details
  WHERE player_name = 'LeBron James'  -- Filter for LeBron James' games
),
-- CTE to calculate streak groups based on consecutive games with over 10 points
streaks AS (
  SELECT 
    player_name,          -- Player name
    game_id,              -- Game ID
    pts,                  -- Points scored in the game
    over_10_pts,          -- Indicator if points scored are over 10
    ROW_NUMBER() OVER (ORDER BY game_id) - 
    ROW_NUMBER() OVER (PARTITION BY over_10_pts ORDER BY game_id) AS streak_group
    -- Calculate streak group by subtracting row numbers
  FROM lebron_games
)
-- Final select to find the maximum length of consecutive games with over 10 points
SELECT 
  player_name,          -- Player name
  MAX(COUNT(*)) OVER (PARTITION BY player_name, streak_group) AS max_consecutive_games_over_10_pts
  -- Calculate maximum count of consecutive games over 10 points
FROM streaks
WHERE over_10_pts = 1  -- Filter for streaks where points scored are over 10
GROUP BY player_name, streak_group  -- Group by player name and streak group
ORDER BY max_consecutive_games_over_10_pts DESC  -- Order by max consecutive games in descending order
LIMIT 1 -- Limit to the top result