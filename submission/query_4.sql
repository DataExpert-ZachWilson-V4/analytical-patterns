WITH game_dates AS (
  SELECT 
    game_date_est,
    game_id,
    game_status_text,
    home_team_id,
    season AS g_season
  FROM bootcamp.nba_games
),

player_game_stats AS (
  SELECT
    g.game_date_est,
    g.game_id,
    g.game_status_text,
    g.home_team_id,
    g.g_season,
    s.player_name,
    s.team_id, 
    s.pts,
    s.reb,
    s.ast
  FROM game_dates g
  JOIN bootcamp.nba_game_details_dedup s
    ON g.game_id = s.game_id
    AND s.team_id = g.home_team_id
),

player_season_stats AS (
  SELECT
    player_name,
    g_season,
    team_id,
    SUM(pts) AS total_pts,
    SUM(reb) AS total_reb,
    SUM(ast) AS total_ast
  FROM player_game_stats
  GROUP BY 
    player_name,
    g_season,
    team_id
),

ranked_stats AS (
  SELECT 
    player_name,
    g_season,
    team_id,
    total_pts,
    total_reb,
    total_ast,
    ROW_NUMBER() OVER (PARTITION BY player_name, g_season ORDER BY total_pts DESC) AS rank
  FROM player_season_stats
)

SELECT 
  player_name,
  g_season,
  team_id,
  total_pts,
  total_reb,
  total_ast,
  rank
FROM ranked_stats
ORDER BY total_pts desc, g_season ASC, rank ASC
limit 1
