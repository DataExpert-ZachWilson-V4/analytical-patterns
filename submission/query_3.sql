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

season_totals AS (
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

game_stats_with_totals AS (
  SELECT
    pgs.game_date_est,
    pgs.game_id,
    pgs.game_status_text,
    pgs.home_team_id,
    pgs.g_season,
    pgs.player_name,
    pgs.team_id,
    pgs.pts,
    pgs.reb,
    pgs.ast,
    st.total_pts,
    st.total_reb,
    st.total_ast,
    ROW_NUMBER() OVER (PARTITION BY pgs.player_name, pgs.g_season ORDER BY pgs.pts DESC) AS rank
  FROM player_game_stats pgs
  JOIN season_totals st
    ON pgs.player_name = st.player_name
    AND pgs.g_season = st.g_season
    AND pgs.team_id = st.team_id
)

SELECT 
  game_date_est,
  game_id,
  game_status_text,
  home_team_id,
  g_season,
  player_name,
  team_id,
  pts,
  reb,
  ast,
  total_pts as total_pts_for_season,
  total_reb as total_reb_for_season,
  total_ast as total_ast_for_season,
  rank
FROM game_stats_with_totals
ORDER BY pts desc, g_season ASC, rank ASC, game_date_est ASC
limit 1
