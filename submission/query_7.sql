WITH lebron_games AS (
    -- Filter LeBron James' games, calculate max points and flag for 10+ points
    SELECT
        d.player_id,
        d.player_name,
        d.game_id,
        g.game_date_est AS game_date,
        MAX(d.pts) AS pts,
        CASE
            WHEN MAX(d.pts) > 10 THEN 1
            ELSE 0
        END AS ten_plus
    FROM
        bootcamp.nba_game_details d
    JOIN
        bootcamp.nba_games g ON d.game_id = g.game_id
    WHERE
        d.player_name = 'LeBron James'
    GROUP BY
        d.player_id,
        d.player_name,
        d.game_id,
        g.game_date_est
),

lagged_scores AS (
    -- Calculate the lagged value of the 'ten_plus' flag
    SELECT
        *,
        LAG(ten_plus) OVER (PARTITION BY player_id ORDER BY game_date) AS lag_window
    FROM
        lebron_games
),

streak_identification AS (
    -- Identify streaks of consecutive 10+ points games
    SELECT
        player_id,
        player_name,
        game_id,
        game_date,
        pts,
        ten_plus,
        SUM(CASE WHEN ten_plus != lag_window THEN 1 ELSE 0 END) OVER (PARTITION BY player_id ORDER BY game_date) AS streak_id
    FROM
        lagged_scores
),

streak_lengths AS (
    -- Calculate the length of each streak of 10+ points games
    SELECT
        player_id,
        player_name,
        COUNT(*) AS streak_length
    FROM
        streak_identification
    GROUP BY
        player_id,
        player_name,
        streak_id
    HAVING
        MAX(ten_plus) = 1
)

-- Select the player_id, player_name, and the maximum streak length of 10+ points
SELECT
    MAX_BY(player_id, streak_length) AS player_id,
    MAX_BY(player_name, streak_length) AS player_name,
    MAX(streak_length) AS no_of_consecutive_over_ten_plus
FROM
    streak_lengths
