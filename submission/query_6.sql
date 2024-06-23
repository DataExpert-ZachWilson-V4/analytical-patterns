-- Query that selects the most games a single team has won in a 90 day streak
WITH 
team_wins AS (
    SELECT DISTINCT --gets only unique team games 
        team_abbreviation,
        g.game_date_est,
        CASE
            WHEN gmdt.team_id = g.home_team_id THEN home_team_wins = 1 -- set team won if hometeam is current team
            ELSE home_team_wins = 0
        END AS team_won
    FROM
        bootcamp.nba_game_details_dedup gmdt
        JOIN bootcamp.nba_games g ON g.game_id = gmdt.game_id
),
win_stretches AS (
    SELECT
        team_abbreviation,
        game_date_est,
        SUM(CAST(team_won AS INTEGER)) OVER (
            PARTITION BY team_abbreviation
            ORDER BY
                game_date_est ASC ROWS BETWEEN 89 PRECEDING
                AND CURRENT ROW
        ) AS ninety_game_win --gets the sum of all games won for a team over a 90 day period 
    FROM
        team_wins
)
SELECT
  team_abbreviation,
    MAX(ninety_game_win) AS ninety_game_win, --gets the maximum games won in a 90 day period
    MAX_BY(game_date_est, ninety_game_win) AS end_stretch_date --gets the end date for the stretch
FROM
    win_stretches
GROUP BY
    team_abbreviation
ORDER BY 2 DESC
LIMIT 1 