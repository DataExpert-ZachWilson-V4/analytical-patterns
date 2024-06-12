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
    COALESCE(season, 0) AS season,
    SUM(CAST(did_win AS INT)) AS wins -- sum of all wins to get total for each aggregate
  FROM combined
  GROUP BY GROUPING SETS (
    (team_name),
    (player_name, team_name),
    (player_name, season)
  )
)
-- Get the number of wins for each team
-- Select the team with the most wins
SELECT
  team_name,
  MAX(wins) AS most_wins
FROM aggregated
WHERE
  player_name = '(overall)'
  AND team_name != '(overall)'
  AND season = 0
GROUP BY team_name
ORDER BY most_wins DESC
LIMIT 1
