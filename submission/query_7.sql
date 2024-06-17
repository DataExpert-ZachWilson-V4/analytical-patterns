-- "How many games in a row did LeBron James score over 10 points a game?"
WITH games_lebron AS (
    SELECT
            game_id,
            player_name,
            team_id,
            team_abbreviation,
            SUM(pts) AS pts_total
        FROM  bootcamp.nba_game_details
        WHERE player_name = 'LeBron James'
        GROUP BY
            game_id,
            team_id,
            team_abbreviation,
            player_name
    ),
over_10_lebron AS (
    SELECT
        gd.game_id,
        gd.player_name,
        g.game_date_est,
        gd.pts_total,
        CASE
            WHEN gd.pts_total > 10 THEN 1
            ELSE 0
        END AS over_10_points
    FROM bootcamp.nba_games g
        JOIN games_lebron gd ON g.game_id = gd.game_id
),
lagged AS (
    SELECT
        game_id,
        player_name,
        game_date_est,
        pts_total,
        over_10_points,
        LAG(over_10_points) OVER (ORDER BY game_date_est) AS over_10_points_prev
    FROM over_10_lebron
),
streaked AS (
    SELECT
        *,
        SUM(CASE
                WHEN over_10_points_prev != over_10_points THEN 1
                ELSE 0
            END) OVER (ORDER BY game_date_est) AS streak_id
    FROM lagged
),
streak_length AS (
    SELECT
        player_name,
        COUNT(1) AS streak_length
    FROM streaked
    GROUP BY player_name, streak_id
    HAVING MAX(over_10_points) = 1
)
SELECT
    player_name,
    MAX(streak_length) AS games_over_10
FROM streak_length
GROUP BY player_name