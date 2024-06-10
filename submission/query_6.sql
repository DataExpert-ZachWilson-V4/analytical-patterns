-- What is the most games a single team has won in a given 90-game stretch?
WITH nba_games_data AS (
    SELECT
        DISTINCT -- Distinct game, team
        gd.game_id,
        gd.team_abbreviation,
        -- need to count only when home team wins
        IF(
            ( -- Home team wins
                gd.team_id = g.home_team_id
                AND g.home_team_wins = 1
            )
            OR ( -- Visitor team wins
                gd.team_id = g.visitor_team_id
                AND g.home_team_wins = 0
            ),
            1,
            0
        ) AS game_won,
        g.game_date_est AS game_date
    FROM
        bootcamp.nba_game_details_dedup AS gd
        JOIN bootcamp.nba_games AS g ON g.game_id = gd.game_id
),
streak AS (
    SELECT
        *,
        SUM(game_won) OVER (PARTITION BY team_abbreviation 
            ORDER BY game_date ASC ROWS BETWEEN 89 PRECEDING AND CURRENT ROW) AS ninety_days_streak 
        -- Rolling sum of the games won in the last 90 games
    FROM
        nba_games_data
)
SELECT
    team_abbreviation,
    -- determine the end date of the longest 90-day streak
    MAX_BY(game_date, ninety_days_streak) AS end_stretch_date,
    -- largest number of won games in a 90-day streak
    MAX(ninety_days_streak) AS n_won_90_games_stretch
FROM
    streak
GROUP BY
    team_abbreviation
ORDER BY
    n_won_90_games_stretch DESC
LIMIT
    1