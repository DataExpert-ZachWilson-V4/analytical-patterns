WITH distinct_games AS (
    -- Select distinct game entries
    SELECT
        game_date_est,
        game_id,
        home_team_id,
        visitor_team_id,
        home_team_wins
    FROM
        bootcamp.nba_games
    GROUP BY
        game_date_est, game_id, home_team_id, visitor_team_id, home_team_wins
),

team_games AS (
    -- Combine home and away games for each team
    SELECT
        game_date_est AS game_date,
        home_team_id,
        visitor_team_id,
        home_team_wins AS is_won
    FROM
        distinct_games
    UNION ALL
    SELECT
        game_date_est AS game_date,
        visitor_team_id AS home_team_id,
        home_team_id AS visitor_team_id,
        1 - home_team_wins AS is_won
    FROM
        distinct_games
),

wins_90_days AS (
    -- Compute 90-day sliding window win totals
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
        team_games
)

-- Select team with max wins in a 90-day window
SELECT
    max_by(home_team_id, number_of_wins) AS team_id,
    max_by(window_start, number_of_wins) AS window_start,
    max_by(window_end, number_of_wins) AS window_end,
    MAX(number_of_wins) AS most_90_days_wins
FROM
    wins_90_days
