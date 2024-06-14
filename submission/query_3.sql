WITH combined AS (
  -- Combine both tables to get info needed for teams and players 
  SELECT
    ngd.team_abbreviation AS team_name,
    ngd.player_name,
    ngd.pts,
    CASE
      WHEN ngd.team_id = ng.home_team_id THEN ng.home_team_wins = 1 -- Assign 1 if the team is the home team and they won
      WHEN ngd.team_id = ng.visitor_team_id THEN ng.home_team_wins = 0  -- Assign 0 if the team is the visitor team and they lost
    END AS did_win  -- Calculated field indicating if the player's team won
  FROM bootcamp.nba_games ng
  INNER JOIN bootcamp.nba_game_details_dedup ngd ON ng.game_id = ngd.game_id
),
aggregated AS (
  -- Apply aggregations by using grouping sets as needed
  SELECT
    team_name,
    player_name,
    SUM(pts) AS points  -- Sum of total points scored by player
  FROM combined
  GROUP BY GROUPING SETS (
    (team_name, player_name)  -- Group by team name and player name
  )
)
-- Get the maximum points scored for each player in each team
-- Select the player with the most points whatever the team 
SELECT
  team_name,
  player_name,
  MAX(points) AS max_points
FROM aggregated
GROUP BY team_name, player_name -- Group by team name and player name
ORDER BY max_points DESC  -- Order by maximum points in descending order
LIMIT 1 -- Limit the result to the top player with the most points
