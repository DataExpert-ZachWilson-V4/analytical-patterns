WITH
    deduped_games as (
        SELECT
            game_date_est,
            home_team_id,
            visitor_team_id,
            home_team_wins
        FROM
            bootcamp.nba_games
        WHERE
            home_team_wins IS NOT NULL
        GROUP BY
            game_date_est,
            home_team_id,
            visitor_team_id,
            home_team_wins
    ),
    games_both_perspectives as (
        SELECT
            game_date_est,
            home_team_id as team_id,
            home_team_wins as is_win
        FROM
            deduped_games
        UNION
        SELECT
            game_date_est,
            visitor_team_id as team_id,
            CASE
                WHEN home_team_wins = 1 THEN 0
                WHEN home_team_wins = 0 THEN 1
            END AS is_win
        FROM
            deduped_games
    ),
    wins_over_90_games as (
        SELECT
            team_id,
            game_date_est - interval '90' day as window_start,
            game_date_est as window_end,
            sum(is_win) OVER (
                PARTITION BY
                    team_id
                ORDER BY
                    game_date_est ROWS BETWEEN 89 PRECEDING
                    AND current ROW
            ) as n_wins
        FROM
            games_both_perspectives
    )
SELECT
    max_by(team_id, n_wins) as team_id,
    max_by(window_start, n_wins) as window_start,
    max_by(window_end, n_wins) as window_end,
    max(n_wins) max_wins_over_90_games
FROM 
    wins_over_90_games
