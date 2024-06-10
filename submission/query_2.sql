-- Grouping Sets for `nba_game_details` aggregations on
-- 1. player and team
-- 2. player and season
-- 3. team

-- Deduplicating the `nba_game_details` table
WITH nba_game_details_deduped AS (
  SELECT
    game_id,
    team_id,
    team_abbreviation,
    player_id,
    player_name,
    pts,
    ROW_NUMBER() OVER (PARTITION BY game_id, team_id, player_id ORDER BY pts DESC) AS row_num
  FROM bootcamp.nba_game_details
),
-- Combining with `nba_games` to retrieve the season
combined AS (
  SELECT
    gd.game_id,
    gd.team_id,
    gd.team_abbreviation,
    gd.player_id,
    gd.player_name,
    gd.pts,
    g.season
  FROM nba_game_details_deduped gd
    JOIN bootcamp.nba_games g ON gd.game_id = g.game_id AND gd.team_id = g.home_team_id
  WHERE
    gd.row_num = 1
),
olap_cube AS (
  SELECT
    COALESCE(CAST(team_id AS VARCHAR), '(overall)') AS team,
    COALESCE(CAST(player_id AS VARCHAR), '(overall)') AS player,
    COALESCE(CAST(season AS VARCHAR), '(overall)') AS season,
    MAX(team_abbreviation) AS team_abbreviation,
    MAX(player_name) AS player_name,
    AVG(pts) AS avg_pts,
    SUM(pts) AS sum_pts
  FROM combined
  GROUP BY GROUPING SETS (
    (player_id, team_id),
    (player_id, season),
    (team_id)
  )
)
SELECT
  *
FROM
  olap_cube