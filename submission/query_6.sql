--
-- Write a query (query_6) that uses window functions on nba_game_details to answer the question:
-- "What is the most games a single team has won in a given 90-game stretch?"
--
-- team_abbreviation	max_wins_over_90_games
-- GSW	                    80
--
-- Deduplicating nba_game_details table to ensure unique player entries per game
WITH nba_game_details_deduped AS (
    SELECT DISTINCT
        game_id,
        team_id,
        team_abbreviation
    FROM academy.bootcamp.nba_game_details
),

-- Deduplicating nba_games table to ensure unique game entries
nba_games_deduped AS (
    SELECT DISTINCT
        game_id,
        team_id_home,
        home_team_wins,
        game_date_est
    FROM academy.bootcamp.nba_games
),

-- Calculating cumulative wins for each team
team_game_results AS (
    SELECT
        ngd.team_id,
        ngd.game_id,
        ngd.team_abbreviation,
        ng.game_date_est,
        SUM(
            CASE
                WHEN ngd.team_id = ng.team_id_home THEN ng.home_team_wins
                ELSE 1 - ng.home_team_wins
            END
        ) OVER (PARTITION BY ngd.team_id ORDER BY ng.game_date_est) AS cumulative_wins
    FROM
        nba_game_details_deduped ngd
        JOIN nba_games_deduped ng ON ngd.game_id = ng.game_id
),

-- Calculating wins over a rolling 90-game window
cumulated_results AS (
    SELECT
        team_id,
        game_id,
        team_abbreviation,
        cumulative_wins - LAG(cumulative_wins, 90, 0) OVER (PARTITION BY team_id ORDER BY game_date_est) AS rolling_90_game_wins
    FROM
        team_game_results
),

-- Selecting the team with the most wins in any 90-game stretch
max_rolling_wins AS (
    SELECT
        team_id,
        team_abbreviation,
        MAX(rolling_90_game_wins) AS max_wins_over_90_games
    FROM
        cumulated_results
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
LIMIT 1 -- remove to see complete list