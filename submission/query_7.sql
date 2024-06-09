-- Create a CTE 'all_games' to filter the data for LeBron James and calculate the maximum points scored and a flag for 10+ points scored
WITH all_games AS (
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
        JOIN bootcamp.nba_games g ON d.game_id = g.game_id
    WHERE
        d.player_name = 'LeBron James'
    GROUP BY
        d.player_id,
        d.player_name,
        d.game_id,
        g.game_date_est
),
-- Create a CTE 'lagged' to calculate the lagged value of the 'ten_plus' flag
lagged AS (
    SELECT
        *,
        LAG(ten_plus) OVER (PARTITION BY player_id ORDER BY game_date) AS lag_window
    FROM
        all_games
),
-- Create a CTE 'streaks' to identify consecutive streaks of 10+ points scored by assigning a streak_id
streaks AS (
    SELECT
        player_id,
        player_name,
        game_id,
        game_date,
        pts,
        ten_plus,
        SUM(CASE WHEN ten_plus != lag_window THEN 1 ELSE 0 END) OVER (PARTITION BY player_id ORDER BY game_date) AS streak_id
    FROM
        lagged
),
-- Create a CTE 'streak_length' to calculate the length of each streak where 10+ points were scored
streak_length AS (
    SELECT
        player_id,
        player_name,
        COUNT(*) AS streak_length
    FROM
        streaks
    GROUP BY
        player_id,
        player_name,
        streak_id
    HAVING
        MAX(ten_plus) = 1
)

-- Select the player_id, player_name, and the maximum streak length
SELECT
    MAX_BY(player_id, streak_length) AS player_id,
    MAX_BY(player_name, streak_length) AS player_name,
    MAX(streak_length) AS no_of_consecutive_over_ten_plus
FROM
    streak_length