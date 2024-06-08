WITH
dedupe AS (
    -- Deduplicate the nba_games table by grouping on the game_date_est, game_id, home_team_id, visitor_team_id, and home_team_wins columns
    SELECT
        game_date_est,
        game_id,
        home_team_id,
        visitor_team_id,
        home_team_wins
    FROM
        bootcamp.nba_games
    GROUP BY
        game_date_est,
        game_id,
        home_team_id,
        visitor_team_id,
        home_team_wins
),
all_combos AS (
    -- Create a combined view of home and away games for each team
    SELECT
        game_date_est AS game_date,
        home_team_id,
        visitor_team_id,
        home_team_wins AS is_won
    FROM
        dedupe
    UNION
    SELECT
        game_date_est AS game_date,
        visitor_team_id AS home_team_id,
        home_team_id AS visitor_team_id,
        CASE
            WHEN home_team_wins = 1 THEN 0
            WHEN home_team_wins = 0 THEN 1
        END AS is_won
    FROM
        dedupe
),
window_90_days AS (
    -- Calculate the number of wins for each team in a 90-day sliding window
    SELECT
        home_team_id,
        game_date - INTERVAL '90' DAY AS window_start,
        game_date AS window_end,
        SUM(is_won) OVER (
            PARTITION BY home_team_id
            ORDER BY game_date
            RANGE BETWEEN INTERVAL '89' DAY PRECEDING AND CURRENT ROW
        ) AS number_of_wins
    FROM
        all_combos
)
SELECT
    -- Find the team with the maximum number of wins in a 90-day window
    max_by(home_team_id, number_of_wins) AS team_id,
    -- Find the corresponding start of the 90-day window with the maximum number of wins
    max_by(window_start, number_of_wins) AS window_start,
    -- Find the corresponding end of the 90-day window with the maximum number of wins
    max_by(window_end, number_of_wins) AS window_end,
    -- Get the maximum number of wins in a 90-day window
    MAX(number_of_wins) AS most_90_days_wins
FROM
    window_90_days