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
      WHEN ngd.team_id = ng.home_team_id THEN ng.home_team_wins = 1
      WHEN ngd.team_id = ng.visitor_team_id THEN ng.home_team_wins = 0
    END AS did_win
  FROM bootcamp.nba_games ng
  INNER JOIN bootcamp.nba_game_details_dedup ngd ON ng.game_id = ngd.game_id
),
aggregated AS (
  -- Apply aggregations by using grouping sets as needed
  SELECT
    COALESCE(team_name, '(overall)') AS team_name,
    COALESCE(player_name, '(overall)') AS player_name,
    COALESCE(season, -1) AS season, -- Use season if available, otherwise use -1
    SUM(pts) AS points  -- Sum of total points scored by player
  FROM combined
  GROUP BY GROUPING SETS (
    (team_name),  -- Group by team name
    (team_name, player_name), -- Group by team name and player name
    (season, player_name) -- Group by season and player name
  )
)
-- Get the maximum points scored for each player in each season
-- Select the player with the most points in a season
SELECT
  season,
  player_name,
  points AS max_points  -- Maximum points scored by the player in the season
FROM aggregated
WHERE
  player_name != '(overall)'  -- Include all rows with player name
  AND team_name = '(overall)' -- Include only overall team name
  AND season != -1  -- Include all rows with season
ORDER BY max_points DESC  -- Order by maximum points in descending order
LIMIT 1 -- Limit the result to the top player with the most points in a season
