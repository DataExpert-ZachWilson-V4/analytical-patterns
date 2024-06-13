WITH lebron_games as (
    -- first we mark games where LeBron scored over 10 and join in game date
    SELECT g.game_date_est,
        CASE
            WHEN gd.pts > 10 THEN 1
            ELSE 0
        END as over_10_pts
    FROM bootcamp.nba_game_details_dedup gd
        LEFT JOIN bootcamp.nba_games g ON gd.game_id = g.game_id
    WHERE player_name = 'LeBron James'
),
lagged as (
    -- then we add a column describing whether previous game LeBron also scored over 10
    SELECT game_date_est,
        over_10_pts,
        LAG(over_10_pts, 1, 0) OVER (
            ORDER BY game_date_est
        ) as over_10_pts_prev_game
    FROM lebron_games
),
streaked as (
    -- we calculate 'streaks' of games when LeBron scored 10 consecutively
    -- the streaks will also include games where he didnt score over 10, but we will filter them out later
    SELECT *,
        SUM(
            CASE
                WHEN over_10_pts = 1
                AND over_10_pts <> over_10_pts_prev_game THEN 1
                ELSE 0
            END
        ) OVER (
            ORDER BY game_date_est
        ) AS streak_identifier
    FROM lagged
)
SELECT COUNT(1) as number_of_games
FROM streaked
WHERE over_10_pts = 1 -- filter out games where LeBron didnt score over 10 but they belong the the streak
GROUP BY streak_identifier
ORDER BY COUNT(1) DESC
LIMIT 1
