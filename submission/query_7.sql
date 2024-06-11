-- CTE to retrieve NBA game data for LeBron James
WITH nba_games_data AS (
    SELECT 
        dedup.game_id, 
        dedup.player_name,
        dedup.pts > 10 AS plus_10_pts,
        games.game_date_est AS game_date
    FROM bootcamp.nba_game_details_dedup AS dedup
    JOIN bootcamp.nba_games AS games ON games.game_id = dedup.game_id
    WHERE dedup.player_name = 'LeBron James'
),

-- CTE to calculate the previous game's plus_10_pts value for each player
lagged AS (
    SELECT 
        *,
        LAG(plus_10_pts, 1) OVER (PARTITION BY player_name ORDER BY game_date ASC) AS last_game_plus_10_pts 
    FROM nba_games_data
)

-- Main query to calculate the streak of consecutive games with plus_10_pts for each player
SELECT
    player_name,
    SUM(IF(plus_10_pts AND last_game_plus_10_pts, 1, 0)) AS streak_plus_10_pts_sum
FROM lagged
GROUP BY player_name