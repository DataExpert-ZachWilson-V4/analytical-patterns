-- a query that uses window functions on `nba_game_details` to answer the question: 
-- "How many games in a row did LeBron James score over 10 points a game?

WITH lbj_games AS (

  SELECT 
    gd.player_name AS player,
    g.game_date_est AS game_dt,
    gd.team_abbreviation AS team_id,
    -- didn't play some games
    COALESCE(gd.pts, 0) AS game_pts
  FROM bootcamp.nba_game_details gd
  LEFT JOIN bootcamp.nba_games g
    ON g.game_id = gd.game_id
  WHERE player_name = 'LeBron James'
  GROUP BY 1, 2, 3, 4

), lbj_games_flag AS (

  SELECT 
    *,
    -- flags for whether or not LBJ hit > 10 pts the current and previous games 
    IF(COALESCE(LAG(game_pts) OVER(ORDER BY game_dt), 0) > 10, 1, 0) AS last_streak_id,
    IF(game_pts > 10, 1, 0) AS streak_id
  FROM lbj_games
  
), lbj_streak AS (

  SELECT *,
    -- a separator for everytime a streak changes
    SUM(CASE 
        -- streak ended this game
        WHEN last_streak_id > streak_id THEN 1
        -- streak remains ended
        WHEN COALESCE(last_streak_id, 0) + streak_id = 0 THEN 1
        ELSE 0
    END) OVER (
        PARTITION BY player ORDER BY game_dt ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS streak_partition
  FROM lbj_games_flag
  
), lbj_cumulative_streak AS (

  SELECT
    player,
    streak_id,
    streak_partition,
    SUM(streak_id) OVER (PARTITION BY player, streak_partition ORDER BY game_dt) AS streaks
  FROM lbj_streak

)
SELECT MAX(streaks) AS longest_streak_count
FROM lbj_cumulative_streak