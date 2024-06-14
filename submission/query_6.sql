WITH combined AS (
  -- Combine both tables to get info needed for teams and players
  SELECT
    ng.game_id,
    ng.game_date_est,
    ngd.team_id,
    ngd.team_abbreviation AS team_name,
    CASE
      WHEN ngd.team_id = ng.home_team_id THEN ng.home_team_wins = 1 -- Assign 1 if the team is the home team and they won
      WHEN ngd.team_id = ng.visitor_team_id THEN ng.home_team_wins = 0  -- Assign 0 if the team is the visitor team and they lost
    END AS did_win, -- Calculated field indicating if the player's team won
    -- Get row number for each game and team
    ROW_NUMBER() OVER (
        PARTITION BY ng.game_id, ngd.team_id -- Partition by game ID and team ID
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
  -- Get rolling window sum of wins for previous 90 games
  SELECT
    *,
    SUM(did_win) OVER (
      PARTITION BY team_id
      ORDER BY game_date_est 
      ROWS BETWEEN 89 PRECEDING AND CURRENT ROW -- Rolling window of 90 games
    ) AS sum_90_game_stretch_wins -- Sum of wins over the last 90 games
  FROM deduped
)
SELECT
  -- Get the team with the maximum wins for a 90-game stretch
  MAX_BY(team_name, sum_90_game_stretch_wins) AS team_name, -- Team with the maximum wins in a 90-game stretch
  MAX(sum_90_game_stretch_wins) AS sum_90_game_stretch_wins -- Maximum wins in a 90-game stretch
FROM window_sum
