WITH combined AS (
  -- Combine both tables to get info needed for teams and players 
  SELECT
    ng.game_id,
    ng.season,
    ngd.team_id,
    ngd.team_abbreviation AS team_name,
    ngd.player_id,
    ngd.player_name,
    ngd.pts,
    CASE
      WHEN ngd.team_id = ng.home_team_id THEN ng.home_team_wins = 1 -- Assign 1 if the team is the home team and they won
      WHEN ngd.team_id = ng.visitor_team_id THEN ng.home_team_wins = 0 -- Assign 0 if the team is the visitor team and they lost
    END AS did_win -- Calculated field indicating if the player's team won

  FROM bootcamp.nba_games ng
  INNER JOIN bootcamp.nba_game_details_dedup ngd ON ng.game_id = ngd.game_id
)
-- Apply aggregations by using grouping sets as needed
SELECT
  COALESCE(team_name, '(overall)') AS team_name,
  COALESCE(player_name, '(overall)') AS player_name,
  COALESCE(season, -1) AS season, -- Use season if available, otherwise use -1
  SUM(pts) AS total_player_points,  -- Sum of total points scored by playerl points 
  SUM(CAST(did_win AS INT)) AS total_team_wins -- Sum of total wins
FROM combined
GROUP BY GROUPING SETS (
  (team_name),  -- Group by team name
  (team_name, player_name), -- Group by team name and player name
  (season, player_name) -- Group by season and player name
)
