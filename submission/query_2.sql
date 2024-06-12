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
)
-- Apply aggregations by using grouping sets as needed
SELECT
  COALESCE(team_name, '(overall)') AS team_name,
  COALESCE(player_name, '(overall)') AS player_name,
  COALESCE(season, 0) AS season
FROM combined
GROUP BY GROUPING SETS (
  (team_name),
  (player_name, team_name),
  (player_name, season)
)
