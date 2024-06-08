WITH
    by_game AS (
        SELECT
            d.player_id,
            d.player_name,
            d.game_id,
            g.game_date_est,
            max(d.pts) as pts,
            CASE
                WHEN max(d.pts) > 10 THEN 1
                ELSE 0
            END AS over_10
        FROM
            bootcamp.nba_game_details d
            INNER JOIN bootcamp.nba_games g on d.game_id = g.game_id
        WHERE
            d.player_id = 2544
        GROUP BY
            d.player_id,
            d.player_name,
            d.game_id,
            g.game_date_est
    ),
    lagged AS (
        SELECT
            player_id,
            player_name,
            game_id,
            game_date_est,
            pts,
            over_10,
            lag(over_10) OVER (
                PARTITION BY
                    player_id
                ORDER BY
                    game_date_est
            ) AS lagged_over_10
        FROM
            by_game
    ),
    streaks as (
        SELECT
            player_id,
            player_name,
            game_id,
            game_date_est,
            pts,
            over_10,
            sum(
                CASE
                    WHEN over_10 != lagged_over_10 THEN 1
                    ELSE 0
                END
            ) OVER (
                PARTITION BY
                    player_id
                ORDER BY
                    game_date_est
            ) AS streak_id
        FROM
            lagged
    ),
    streak_lengths as (
        select
            player_id,
            player_name,
            count(1) as length_of_streak
        from
            streaks
        group by
            player_id,
            player_name,
            streak_id
        having
            max(over_10) = 1
    )
select
    max_by(player_id, length_of_streak) as player_id,
    max_by(player_name, length_of_streak) as player_name,
    max(length_of_streak) as n_consecutive_games_player_scored_over_10_pts
from
    streak_lengths
WHERE
    player_id = 2544
