CREATE OR REPLACE TABLE ykshon52797255.nba_grouping_sets AS (
WITH
 combined AS (
  select g.home_team_id,
    g.visitor_team_id,
    COALESCE(gd.player_id, 0) AS player_id,
    COALESCE(gd.player_name, 'N/A') AS player_name,
    gd.pts,
    COALESCE(gd.team_id, 0) AS team_id,
    COALESCE(gd.team_abbreviation, 'N/A') AS team_abbreviation,
    g.home_team_wins,
    COALESCE(g.season, 9999) AS season
  from bootcamp.nba_games g
  JOIN bootcamp.nba_game_details_dedup gd
  on g.game_id = gd.game_id
 )
  
SELECT COALESCE(player_name, '(overall)') AS player_name,
  COALESCE(team_abbreviation, '(overall)') AS team_abbreviation,
  COALESCE(season, 9999) AS season,
  SUM(pts) as pts,
  CAST(COUNT(case
    when team_id = home_team_id and home_team_wins = 1 THEN 1
    when team_id = visitor_team_id and home_team_wins = 0 THEN 1
  END) AS REAL)
 AS team_wins
FROM combined
GROUP BY
 GROUPING SETS (
 (player_name, team_id, team_abbreviation),
 (player_name, season),
 (team_id, team_abbreviation)
 )
 )
