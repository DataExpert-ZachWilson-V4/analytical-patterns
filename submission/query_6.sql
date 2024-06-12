-- CTE to record game details data for each unique player per game
WITH nba_game_details_deduped AS (
    SELECT DISTINCT
        game_id,
        team_id,
        team_abbreviation
    FROM bootcamp.nba_game_details
),

-- CTE to record game data for each unique game
nba_games_deduped AS (
    SELECT DISTINCT
        game_id,
        team_id_home,
        home_team_wins,
        game_date_est
    FROM bootcamp.nba_games
),

-- CTE to calculate cummulative wins
cummulative_team_wins AS (
    SELECT
        gd.team_id,
        gd.game_id,
        gd.team_abbreviation,
        g.game_date_est,
        SUM(
            CASE
                WHEN gd.team_id = g.team_id_home THEN g.home_team_wins
                ELSE 1 - g.home_team_wins
            END
        ) OVER (PARTITION BY gd.team_id ORDER BY g.game_date_est) AS cumulative_wins
    FROM
        nba_game_details_deduped gd
        JOIN nba_games_deduped g ON gd.game_id = g.game_id
),

-- CTE to record total wins OVER a 90 game sliding window
over_90_game_sliding AS (
    SELECT
        team_id,
        game_id,
        team_abbreviation,
        cumulative_wins - LAG(cumulative_wins, 90, 0) OVER (PARTITION BY team_id ORDER BY game_date_est) AS rolling_90_game_wins
    FROM
        cummulative_team_wins
),

-- CTE to track team with most wins
max_rolling_wins AS (
    SELECT
        team_id,
        team_abbreviation,
        MAX(rolling_90_game_wins) AS max_wins_over_90_games
    FROM
        over_90_game_sliding
    GROUP BY
        team_id,
        team_abbreviation
)

SELECT
    team_abbreviation,
    max_wins_over_90_games
FROM
    max_rolling_wins
ORDER BY
    max_wins_over_90_games DESC
LIMIT 1