-- CTE to record player data for LeBron James where he scored more than 10 points
WITH game_data AS (
    SELECT 
        DISTINCT g.game_date_est,
        gd.player_id, 
        gd.player_name,
        gd.game_id,
        gd.pts,
        CASE 
            WHEN gd.pts > 10 then 1
            ELSE 0 
        END AS won_10_games
    FROM bootcamp.nba_game_details gd 
    JOIN bootcamp.nba_games g 
    ON gd.game_id = g.game_id
    WHERE gd.player_name = 'LeBron James'
    AND gd.pts > 0

),
-- CTE to track prior values for player data 
prior_data AS (
    SELECT 
        *,
        lag(won_10_games,1) over (PARTITION BY player_id ORDER BY game_date_est) AS prev_won_10_games
    FROM game_data
),
-- CTE to track streak 
streak_data AS (
    SELECT 
        player_id,
        player_name,
        game_id,
        pts,
        won_10_games,
        sum(CASE WHEN won_10_games != prev_won_10_games then 1 ELSE 0 END) OVER (PARTITION BY player_id ORDER BY game_date_est) AS streak_id 
    FROM prior_data 
),
-- CTE to record streak duration
streak_length AS (
    SELECT 
        player_id, 
        player_name, 
        COUNT(1) AS streak_duration
    FROM streak_data
    group by 
        player_id, 
        player_name, 
        streak_id 
    having MAX(won_10_games) = 1
)
SELECT 
    MAX_BY(player_id, streak_duration) AS player_id,
    MAX_BY(player_name, streak_duration) AS player_name,
    MAX(streak_duration) AS game_streak_with_over_10_points
FROM streak_length
