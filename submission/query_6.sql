WITH team_wins AS (
    SELECT
        ngd.team_id,
        ngd.team_abbreviation,
        ngd.game_id,
        ng.game_date_est,
        CASE
            WHEN ng.home_team_id = ngd.team_id AND ng.home_team_wins = 1 THEN 1
            WHEN ng.visitor_team_id = ngd.team_id AND ng.home_team_wins = 0 THEN 1
            ELSE 0
        END AS win
    FROM
        bootcamp.nba_game_details ngd
    JOIN
        bootcamp.nba_games ng ON ng.game_id = ngd.game_id
    GROUP BY
        ngd.team_id, ngd.team_abbreviation, ngd.game_id, ng.game_date_est, ng.home_team_id, ng.visitor_team_id, ng.home_team_wins
),
team_games AS (
    SELECT
        team_id,
        team_abbreviation,
        game_date_est,
        win,
        ROW_NUMBER() OVER (PARTITION BY team_id ORDER BY game_date_est) AS game_num
    FROM
        team_wins
),
rolling_wins AS (
    SELECT
        team_id,
        team_abbreviation,
        game_num,
        SUM(win) OVER (PARTITION BY team_id ORDER BY game_num ROWS BETWEEN 89 PRECEDING AND CURRENT ROW) AS wins_90_game
    FROM
        team_games
)
SELECT
    team_id,
    team_abbreviation,
    MAX(wins_90_game) AS max_wins_in_90_games
FROM
    rolling_wins
GROUP BY
    team_id, team_abbreviation
ORDER BY
    max_wins_in_90_games DESC
LIMIT 1
