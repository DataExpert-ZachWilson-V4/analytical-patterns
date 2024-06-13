/*
Write a query (query_7) that uses window functions 
on nba_game_details to answer the question: 
"How many games in a row did LeBron James score over 10 points a game?"
*/

WITH nba_game_details_deduped AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY game_id, team_id, player_id) row_number 
    FROM bootcamp.nba_game_details
),
    
combined AS (
    SELECT
        gd.player_name,
        gd.game_id,
        g.game_date_est,
        CASE WHEN gd.pts > 10 THEN 1 
            ELSE 0
        END AS scored_over_10_pts,
        LAG (
            CASE WHEN gd.pts > 10 THEN 1 
                ELSE 0
            END,
            1,
            0
        ) OVER (
            PARTITION BY gd.player_name 
            ORDER BY g.game_date_est
        ) AS lagged_streak
    FROM bootcamp.nba_games g 
    INNER JOIN nba_game_details_deduped gd 
        ON g.game_id = gd.game_id 
        AND gd.row_number = 1
),

streaks AS (
    SELECT *,
        SUM(
            CASE WHEN scored_over_10_pts = 1 and lagged_streak = 1 THEN 0
                WHEN scored_over_10_pts = 1 and lagged_streak = 0 THEN 0
            ELSE 1 
            END
        ) OVER (
            PARTITION BY player_name 
            ORDER BY game_date_est
        ) AS streak_identifier
    FROM combined
)

SELECT player_name, 
    COUNT(*) AS consecutive_games_over_10_pts
FROM streaks
WHERE scored_over_10_pts = 1
    AND player_name = 'LeBron James'
GROUP BY player_name, streak_identifier
ORDER BY COUNT(*) DESC
LIMIT 1