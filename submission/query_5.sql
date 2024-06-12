-- Which team has won the most games
-- CTE to calculate the total wins for each team
WITH team_games_won AS (
  SELECT 
    team,  -- Select the team
    SUM(total_games_won) AS total_wins  -- Sum of total games won by the team
  FROM sanniepatron.grouping_sets  -- From the grouping_sets table
  WHERE team <> 'N/A'  -- Exclude records where the team is 'N/A'
  GROUP BY team  -- Group by team to get the sum of wins for each team
),

-- CTE to rank teams based on their total wins
ranked_team_games_won AS (
  SELECT 
    team,  -- Select the team
    total_wins,  -- Select the total wins
    DENSE_RANK() OVER (ORDER BY total_wins DESC) AS rank  -- Rank the teams based on total wins in descending order
  FROM team_games_won  -- From the team_games_won CTE
)

-- Final query to select the team and total wins of the team with the most wins
SELECT 
  team,  -- Select the team
  total_wins  -- Select the total wins
FROM ranked_team_games_won  -- From the ranked_team_games_won CTE
WHERE rank = 1  -- Filter to get the team(s) with the highest rank (most wins)