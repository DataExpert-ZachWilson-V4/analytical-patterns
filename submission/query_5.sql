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
      WHEN ngd.team_id = ng.visitor_team_id THEN ng.home_team_wins = 0  -- Assign 0 if the team is the visitor team and they lost
    END AS did_win  -- Calculated field indicating if the player's team won
  FROM bootcamp.nba_games ng
  INNER JOIN bootcamp.nba_game_details_dedup ngd ON ng.game_id = ngd.game_id
),
aggregated AS (
  -- Apply aggregations by using grouping sets as needed 
  SELECT
    COALESCE(team_name, '(overall)') AS team_name,
    COALESCE(player_name, '(overall)') AS player_name,
    COALESCE(season, -1) AS season,
    SUM(CAST(did_win AS INT)) AS wins -- Sum of all wins to get total for each aggregate
  FROM combined
  GROUP BY GROUPING SETS (
    (team_name),  -- Group by team name
    (team_name, player_name), -- Group by team name and player name
    (season, player_name) -- Group by season and player name
  )
)
-- Get the number of wins for each team
-- Select the team with the most wins
SELECT
  team_name,
  wins AS most_wins
FROM aggregated
WHERE
  player_name = '(overall)' -- Discard player_name aggregation results
  AND team_name != '(overall)'  -- Include all rows with team_name
  AND season = -1 -- Discard seaon aggregation results
ORDER BY most_wins DESC -- Order by most wins in descending order
LIMIT 1 -- Limit the result to the top team with the most wins
