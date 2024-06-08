WITH
    combined AS (
        SELECT
            gd.player_name,
            gd.pts,
            game_date_est,
            -- Since the game dates are not daily games in a row we rank rows here
            -- to find an one incremental sequence
            ROW_NUMBER() OVER (
                ORDER BY
                    game_date_est
            ) AS game_number,
            -- This tell us streaks of >10 points but also
            -- for <= 10 points
            RANK() OVER (
                PARTITION BY
                    (
                        CASE
                            WHEN pts > 10 THEN 1
                            ELSE 0
                        END
                    )
                ORDER BY
                    game_date_est
            ) AS streak
        FROM
            bootcamp.nba_games g
            JOIN bootcamp.nba_game_details_dedup gd ON g.game_id = gd.game_id
        WHERE
            gd.player_name = 'LeBron James'
    ),
    grouped AS (
        SELECT
            *,
            -- Here we filter out the streaks with <= 10 pts
            -- they will be in a null group, while
            -- the >10 pts will be grouped based on the row(game number) - the streak
            CASE
                WHEN pts > 10 THEN RANK() OVER (
                    ORDER BY
                        game_number
                ) - streak
            END AS row_group
        FROM
            combined
    )
-- Finally we count the >10 pts streaks
-- here we show all the streaks with >10 pts and their duration
SELECT
    COUNT(1) as ten_pts_streak,
    MIN(game_number) as intial_game,
    MAX(game_number) as final_game,
    MIN(game_date_est) as intial_game_date_est,
    MAX(game_date_est) as final_game_date_est
FROM
grouped
WHERE row_group IS NOT NULL
GROUP BY row_group
ORDER BY ten_pts_streak