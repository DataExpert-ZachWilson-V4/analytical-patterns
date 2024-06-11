WITH
    ngd AS (
        SELECT DISTINCT
            game_id,
            team_id
        FROM
            bootcamp.nba_game_details_dedup
    ),
    base AS (
        SELECT
            ngd.*,
            CASE
                WHEN ng_h.home_team_wins = 1 THEN 1
                ELSE 0
            END + CASE
                WHEN ng_v.home_team_wins = 0 THEN 1
                ELSE 0
            END AS win
        FROM
            ngd
            LEFT JOIN bootcamp.nba_games ng_h ON ng_h.game_id = ngd.game_id
            AND ng_h.home_team_id = ngd.team_id
            LEFT JOIN bootcamp.nba_games ng_v ON ng_v.game_id = ngd.game_id
            AND ng_v.visitor_team_id = ngd.team_id
    ),
    win_streak AS (
        SELECT
            *,
            sum(win) OVER (
                PARTITION BY
                    team_id
                ORDER BY
                    game_id ROWS BETWEEN 89 PRECEDING
                    AND CURRENT ROW
            ) AS game_win_streak_90days
        FROM
            base
    ),
    rank_win_streak AS (
        SELECT
            *,
            DENSE_RANK() OVER (
                ORDER BY
                    game_win_streak_90days DESC
            ) AS RANK
        FROM
            win_streak
    )
SELECT
    *
FROM
    rank_win_streak
WHERE
    RANK = 1
