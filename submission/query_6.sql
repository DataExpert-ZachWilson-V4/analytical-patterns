WITH combined AS (
  SELECT
    ng.game_id,
    ng.game_date_est,
    ngd.team_id,
    ngd.team_abbreviation AS team_name,
    CASE
      WHEN ngd.team_id = ng.home_team_id THEN ng.home_team_wins = 1
      WHEN ngd.team_id = ng.visitor_team_id THEN ng.home_team_wins = 0
    END AS did_win,
    ROW_NUMBER() OVER (
        PARTITION BY ng.game_id, ngd.team_id
    ) AS row_num
  FROM bootcamp.nba_games ng
  INNER JOIN bootcamp.nba_game_details_dedup ngd ON ng.game_id = ngd.game_id
),
deduped AS (
  SELECT
    game_id,
    game_date_est,
    team_id,
    team_name,
    CAST(did_win AS INT) AS did_win
  FROM combined
  WHERE row_num = 1
),
window_sum AS (
  SELECT
    *,
    SUM(did_win) OVER (
      PARTITION BY team_id
      ORDER BY game_date_est 
      ROWS BETWEEN 0 PRECEDING AND 89 FOLLOWING
    ) AS sum_90_game_stretch_wins
  FROM deduped
)
SELECT
  MAX_BY(team_name, sum_90_game_stretch_wins) AS team_name,
  MAX(sum_90_game_stretch_wins) AS sum_90_game_stretch_wins
FROM window_sum
