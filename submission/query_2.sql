--Write a query (query_2) that uses GROUPING SETS to perform aggregations of the nba_game_details data. Create slices that aggregate along the following combinations of dimensions:
--player and team
--player and season
--team
--Build additional queries on top of the results of the GROUPING SETS aggregations above
CREATE OR REPLACE TABLE faraanakmirzaei15025.nba_stats_summary (
    team_abbr VARCHAR,
    player_name VARCHAR,
    season VARCHAR,
    ttl_points_score DOUBLE,
    ttl_wins BIGINT
  )
WITH
  (FORMAT = 'PARQUET', partitioning = ARRAY['season', 'team_abbr'])

INSERT INTO faraanakmirzaei15025.nba_stats_summary
WITH dedup_game_details AS (
  SELECT 
    *
  FROM (
    SELECT 
      *,
      ROW_NUMBER() OVER(PARTITION BY game_id, team_id) AS rn_nba_game_details
    FROM bootcamp.nba_game_details
  ) AS t
  WHERE rn_nba_game_details = 1
)

,dedup_nba_games AS (
  SELECT 
    *
  FROM (
    SELECT 
      *,
      ROW_NUMBER() OVER(PARTITION BY game_id ORDER BY game_date_est DESC) AS rn_nba_games
    FROM bootcamp.nba_games
  ) AS t
  WHERE rn_nba_games = 1
)

,game_player_summary AS (
  SELECT
    gd.team_abbreviation AS team_abbr,
    gd.player_id,
    gd.player_name,
    COALESCE(gd.pts, 0) AS pts,
    CASE 
      WHEN g.home_team_id = gd.team_id
        THEN 'home'
      ELSE
        'visitor'
    END as match_category,
    CASE 
      WHEN g.home_team_wins = 1
        THEN 'home_win'
      ELSE
        'visitor_win'
    END AS match_result,
    g.season AS season
    
  FROM dedup_game_details AS gd
  INNER JOIN dedup_nba_games AS g 
  ON gd.game_id = g.game_id
)

,team_player_summary AS (
  SELECT 
    COALESCE(team_abbr, 'overall') AS team_abbr,
    COALESCE(player_name, 'overall') AS player_name,
    COALESCE(CAST(season AS VARCHAR), 'overall') AS season,
    SUM(pts) AS ttl_points_scored,
    SUM(
      CASE 
        WHEN (match_category='home' AND match_result='home_win') OR 
             (match_category='visitor' AND match_result='visitor_win')
             THEN 1
        ELSE 0
      END
    ) AS team_wins
  FROM game_player_summary
  GROUP BY 
    COALESCE(team_abbr, 'overall'), 
    COALESCE(player_name, 'overall'), 
    COALESCE(CAST(season AS VARCHAR), 'overall')
)

SELECT 
  team_abbr,
  COALESCE(player_name, 'overall') AS player_name,
  COALESCE(CAST(season AS VARCHAR), 'overall') AS season,
  SUM(ttl_points_scored) AS ttl_points_scored,
  SUM(team_wins) AS team_wins
FROM team_player_summary
GROUP BY GROUPING SETS (
  (player_name, team_abbr),
  (player_name, season),
  (team_abbr)
)