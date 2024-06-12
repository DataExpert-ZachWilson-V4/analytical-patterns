--"Which player scored the most points playing for a single team?"
-- CTE to calculate the total points scored by each player for each team
WITH player_team_points AS (
  SELECT 
    player AS player,  -- Select the player
    team AS team,  -- Select the team
    SUM(total_pts) AS total_points  -- Sum of total points scored by the player for the team
  FROM sanniepatron.grouping_sets  -- From the grouping_sets table
  WHERE player IS NOT NULL AND team <> 'N/A'  -- Exclude records where player is NULL or team is 'N/A'
  GROUP BY player, team  -- Group by player and team to get the sum of points for each combination
),

-- CTE to rank players based on their total points for a team
ranked_player_team_points AS (
  SELECT 
    player,  -- Select the player
    team,  -- Select the team
    total_points,  -- Select the total points
    DENSE_RANK() OVER (ORDER BY total_points DESC) AS rank  -- Rank the players based on total points in descending order
  FROM player_team_points  -- From the player_team_points CTE
) 

-- Final query to select the player, team, and total points of the player with the highest points for a single team
SELECT 
  player,  -- Select the player
  team,  -- Select the team
  total_points  -- Select the total points
FROM ranked_player_team_points  -- From the ranked_player_team_points CTE
WHERE rank = 1  -- Filter to get the player(s) with the highest rank (most points)