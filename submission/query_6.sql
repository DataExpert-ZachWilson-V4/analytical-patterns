WITH 
nba_games_unnest AS (
    SELECT 
        game_id,
        team_info.team_id,
        team_info.win
    FROM 
        bootcamp.nba_games,
        -- creates two rows, one for each team in a game with the result
        UNNEST(ARRAY[
            ROW(home_team_id, home_team_wins),
            ROW(visitor_team_id, CASE WHEN home_team_wins = 1 THEN 0 ELSE 1 END)
        ]) AS team_info (team_id, win)
),
running_total AS (
    SELECT
        game_id,
        team_id,
        win,
        SUM(win) OVER (PARTITION BY team_id ORDER BY game_id DESC ROWS BETWEEN 89 PRECEDING AND CURRENT ROW) AS wins_in_90_games
    FROM
        nba_games_unnest
)
SELECT
    team_id,
    MAX(wins_in_90_games) AS max_wins_in_90_games
FROM
    running_total
GROUP BY
    team_id
ORDER BY
    max_wins_in_90_games DESC
LIMIT 1