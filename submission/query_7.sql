-- How many games in a row did LeBron James score over 10 points a game?

-- CTE to dedupe and retrieve LeBron James' games where he scored over 10 points
WITH lebron_10_points_games AS (
    SELECT DISTINCT
        g.game_date_est,
        CASE
            WHEN gd.pts > 10 THEN 1
            ELSE 0
        END AS scored_over_10_points
    FROM
        bootcamp.nba_game_details gd
        JOIN bootcamp.nba_games g ON gd.game_id = g.game_id
    WHERE
        player_name = 'LeBron James'
),
streaks AS (
    SELECT
        game_date_est,
        scored_over_10_points,
        -- Window function to identify streaks
        ROW_NUMBER() OVER (ORDER BY game_date_est) - 
        ROW_NUMBER() OVER (PARTITION BY scored_over_10_points ORDER BY game_date_est) AS streak_identifier
    FROM
        lebron_10_points_games
)
SELECT
    COUNT(1) AS number_of_games
FROM
    streaks
WHERE
    scored_over_10_points = 1
GROUP BY
    streak_identifier
ORDER BY
    number_of_games DESC
LIMIT 1
