-- Query that gets the max consecutive times Lebron James scored 10 pts
WITH  
player_games AS (
    SELECT
        player_name,
        gmdt.game_id,
        g.game_date_est,
        ROW_NUMBER() OVER (PARTITION BY gmdt.game_id, gmdt.player_name, g.game_date_est ORDER BY g.game_date_est) AS game_num, -- gets unique games for a player for a date
        IF(gmdt.pts > 10, 1, 0) AS over_ten_pts -- flag to check if points > 10
    FROM
        bootcamp.nba_game_details_dedup gmdt
        JOIN bootcamp.nba_games g ON g.game_id = gmdt.game_id
    WHERE
        player_name = 'LeBron James'
),
lagged_games AS (
    SELECT *,
        LAG(over_ten_pts, 1) OVER (PARTITION BY player_name ORDER BY game_date_est) AS prev_over_ten_pts  -- Use LAG to get the previous games over_ten_pts for comparison
    FROM
        player_games
    WHERE
        game_num = 1 -- filter to include only unique games
),
streaks AS (
    SELECT *,
        SUM(CASE WHEN over_ten_pts = 0 THEN 1 ELSE 0 END) OVER (PARTITION BY player_name ORDER BY game_date_est) AS streak_id  --  Create streak_id that increments when over_ten_pts is 0, resetting the streak
    FROM
        lagged_games
),
consecutive_games AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY player_name, streak_id ORDER BY game_date_est) AS running_consecutive_games  -- Calculate running count of consecutive games within each streak_id 
    FROM
        streaks
    WHERE
        over_ten_pts = 1 -- filter to include only games where points > 10
)
SELECT
    player_name,
    MAX(running_consecutive_games) AS max_consecutive_games -- gets the maximum consecutive games
FROM
    consecutive_games
GROUP BY
    player_name 
