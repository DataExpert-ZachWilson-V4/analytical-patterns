WITH combined AS (
  -- Combine both tables to get info needed for teams and players
  SELECT
    ng.game_id,
    ng.game_date_est,
    ngd.team_id,
    ngd.team_abbreviation AS team_name,
    CASE
      WHEN ngd.team_id = ng.home_team_id THEN ng.home_team_wins = 1
      WHEN ngd.team_id = ng.visitor_team_id THEN ng.home_team_wins = 0
    END AS did_win,
    -- Get row number for each game and team
    ROW_NUMBER() OVER (
        PARTITION BY ng.game_id, ngd.team_id
    ) AS row_num
  FROM bootcamp.nba_games ng
  INNER JOIN bootcamp.nba_game_details_dedup ngd ON ng.game_id = ngd.game_id
),
deduped AS (
  -- Make all rows to be unique on game_id and team_id by deduping
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
  -- Get rolling window sum of wins for 90 games
  SELECT
    *,
    SUM(did_win) OVER (
      PARTITION BY team_id
      ORDER BY game_date_est 
      ROWS BETWEEN 0 PRECEDING AND 89 FOLLOWING -- for the next (0 to 89) 90 games
    ) AS sum_90_game_stretch_wins
  FROM deduped
)
SELECT
  -- Get maximum wins for 90 game stretch
  MAX_BY(team_name, sum_90_game_stretch_wins) AS team_name,
  MAX(sum_90_game_stretch_wins) AS sum_90_game_stretch_wins
FROM window_sum
