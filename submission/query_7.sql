WITH
    base AS (
        SELECT
            game_id,
            CASE
                WHEN fgm > 10 THEN 1
                ELSE 0
            END AS over_10pt
        FROM
            bootcamp.nba_game_details_dedup
        WHERE
            player_name = 'LeBron James'
    ),
    LAG AS (
        SELECT
            *,
            lag(over_10pt) OVER (
                ORDER BY
                    game_id
            ) AS lag_over_10pt
        FROM
            base
        ORDER BY
            game_id
    ),
    compare AS (
        SELECT
            *,
            CASE
                WHEN over_10pt <> lag_over_10pt THEN 1
                ELSE 0
            END AS streak_identifier
        FROM
            LAG
    ),
    streak_id AS (
        SELECT
            *,
            SUM(streak_identifier) OVER (
                ORDER BY
                    game_id
            ) AS RANK
        FROM
            compare
    ),
    streaks AS (
        SELECT
            sum(over_10pt) streak_over_10pt
        FROM
            streak_id
        WHERE
            over_10pt > 0
        GROUP BY
            RANK
        ORDER BY
            streak_over_10pt DESC
    )
SELECT
    streak_over_10pt,
    count(1) AS streak_over_10pt_times
FROM
    streaks
GROUP BY
    streak_over_10pt
ORDER BY
    streak_over_10pt DESC