-- a query (`query_6`) that uses window functions on `nba_game_details` to answer the question: 
-- "What is the most games a single team has won in a given 90-game stretch?"

WITH games_won AS (

  SELECT 
    game_date_est AS game_dt,
    game_id,
    home_team_id AS team_id,
    COUNT(game_id) OVER(PARTITION BY home_team_id ORDER BY game_date_est) AS team_game_tally,
    home_team_wins AS won_game,
    LAG(home_team_wins, 1) OVER(PARTITION BY home_team_id ORDER BY game_date_est) AS won_last_game
  FROM bootcamp.nba_games

), games_streak AS (

  SELECT
    game_dt,
    game_id,
    team_id,
    team_game_tally,
    -- CEILING(team_game_tally%90) AS game_90_stretch,
    -- game winning streak
    COALESCE(won_last_game, 0) AS won_last_game,
    won_game,
    SUM(
      CASE
      WHEN COALESCE(won_last_game, 0) + won_game = 0 THEN 0
      WHEN COALESCE(won_last_game, 0) > won_game THEN 1
      ELSE 0
      END)
      OVER(PARTITION BY team_id ORDER BY game_dt ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS streak_partition
  FROM games_won
  
), winning_streaks AS (

  SELECT 
    team_id,
    team_game_tally,
    SUM(won_game) OVER(PARTITION BY team_id, streak_partition ORDER BY game_dt) AS streak_ct
  FROM games_streak
  
), game_stretch AS (
  SELECT
    team_id,
    MAX(streak_ct) AS longest_winning_streak
  FROM winning_streaks
  -- only if its within 90 games
  WHERE team_game_tally >= 90
  GROUP BY 1
  
)
-- 1610612759, 40 games
SELECT longest_winning_streak
FROM game_stretch
ORDER BY 1 DESC
LIMIT 1