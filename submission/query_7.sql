--
-- Write a query (query_7) that uses window functions on nba_game_details to answer the question:
-- "How many games in a row did LeBron James score over 10 points a game?"
-- player_name	max_streak_length
--
-- LeBron James	974
--

WITH lebron_games AS (
    -- Select games played by LeBron James and flag games where he scored more than 10 points
    SELECT
        game_id,
        team_id,
        player_name,
        pts,
        CASE
            WHEN pts > 10 THEN 1 -- Flagging games where LeBron scored more than 10 points
            ELSE 0
        END AS over_10_points
    FROM
        academy.bootcamp.nba_game_details
    WHERE
        player_name = 'LeBron James' -- Filtering for games played by LeBron James
        AND pts IS NOT NULL
),

streaks AS (
    -- Calculate streaks by using a window function to determine when the streaks reset
    SELECT
        game_id,
        team_id,
        player_name,
        pts,
        over_10_points,
        SUM(
            CASE
                WHEN over_10_points = 0 THEN 1 -- Increment reset_streak when a game with <= 10 points is encountered
                ELSE 0
            END
        ) OVER (
            PARTITION BY player_name
            ORDER BY game_id
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS reset_streak -- This creates a cumulative sum to identify streaks
    FROM
        lebron_games
),

streak_lengths AS (
    -- Calculate the length of each streak using row number
    SELECT
        player_name,
        game_id,
        pts,
        over_10_points,
        reset_streak,
        ROW_NUMBER() OVER (
            PARTITION BY player_name, reset_streak
            ORDER BY game_id
        ) AS streak_length -- Numbering rows within each streak
    FROM
        streaks
)

-- Find the maximum streak length for LeBron James
SELECT
    player_name,
    MAX(streak_length) AS max_streak_length -- Maximum streak length where LeBron scored over 10 points
FROM
    streak_lengths
WHERE
    over_10_points = 1 -- Only consider the games where LeBron scored over 10 points
GROUP BY
    player_name
