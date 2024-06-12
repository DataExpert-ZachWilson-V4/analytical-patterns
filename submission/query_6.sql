-- CTE to calculate the number of wins for each team in the last 90 games
WITH team_win_streaks AS (
  SELECT 
    team_id,  -- Select the team ID
    a.game_id,  -- Select the game ID
    -- Calculate the number of wins in the last 90 games using a sliding window
    SUM(CASE
          WHEN (team_id = home_team_id AND home_team_wins = 1) 
          OR (team_id = visitor_team_id AND home_team_wins = 0) THEN 1
          ELSE 0
        END) OVER (
          PARTITION BY team_id  -- Partition by team ID
          ORDER BY a.game_id  -- Order by game ID
          ROWS BETWEEN 89 PRECEDING AND CURRENT ROW  -- Define the window of 90 games (current game and 89 preceding games)
        ) AS win_count_last_90_games  -- Alias for the count of wins in the last 90 games
  FROM bootcamp.nba_game_details a  -- From the nba_game_details table
  JOIN bootcamp.nba_games b  -- Join with the nba_games table
  ON a.game_id = b.game_id  -- On matching game ID
),

-- CTE to rank the teams based on the number of wins in the last 90 games
ranked_team_win_streaks AS (
  SELECT 
    team_id,  -- Select the team ID
    win_count_last_90_games,  -- Select the count of wins in the last 90 games
    row_number() OVER (ORDER BY win_count_last_90_games DESC) AS rank  -- Rank the teams based on the count of wins in descending order
  FROM team_win_streaks  -- From the team_win_streaks CTE
)

-- Final query to select the team ID and the maximum number of wins in a 90-game stretch
SELECT 
  team_id,  -- Select the team ID
  win_count_last_90_games AS max_wins_in_90_games  -- Alias for the maximum number of wins in a 90-game stretch
FROM ranked_team_win_streaks  -- From the ranked_team_win_streaks CTE
WHERE rank = 1  -- Filter to get the team with the highest rank (most wins in a 90-game stretch)