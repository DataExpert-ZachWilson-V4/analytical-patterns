WITH combined AS (
  -- Combine both tables to get info needed for teams and players
  SELECT
    ng.game_id,
    ng.game_date_est,
    ngd.team_id,
    ngd.team_abbreviation AS team_name,
    ngd.player_id,
    ngd.player_name,
    ngd.pts,
    CASE
      WHEN ngd.pts > 10 Then 1
      ELSE 0
    END AS is_more_than_10_pts
  FROM bootcamp.nba_games ng
  INNER JOIN bootcamp.nba_game_details_dedup ngd ON ng.game_id = ngd.game_id
  WHERE player_name = 'LeBron James'
),
ranking AS (
  -- using row number to divide each streak using the concept of islands and gaps
  SELECT
    *,
    ROW_NUMBER() OVER (
      PARTITION BY player_name 
      ORDER BY game_date_est
    ) - ROW_NUMBER() OVER (
      PARTITION BY player_name, is_more_than_10_pts 
      ORDER BY game_date_est
    ) AS rnk
  FROM combined
),
streak AS (
  -- sum all streaks for each player 
  SELECT
    player_name,
    rnk,
    SUM(is_more_than_10_pts) AS sum_games_more_than_10
  FROM ranking
  GROUP BY player_name, rnk
)
-- Get maximum streak and the player
SELECT
  MAX_BY(player_name, sum_games_more_than_10) AS player_name,
  MAX(sum_games_more_than_10) AS sum_games_more_than_10
FROM streak
