WITH nba_games_data AS (
    -- Subquery to retrieve relevant data from nba_game_details_dedup and nba_games tables
    SELECT DISTINCT
        dedup.game_id,
        dedup.team_abbreviation AS team,
        CASE
            -- Determine if the team won the match based on home_team_id, visitor_team_id, and home_team_wins
            WHEN games.home_team_id = dedup.team_id AND home_team_wins = 1 THEN 1
            WHEN games.visitor_team_id = dedup.team_id AND home_team_wins = 0 THEN 1
            WHEN home_team_wins IS NULL THEN NULL
            ELSE NULL
        END AS match_won, 
        games.game_date_est AS game_date
    FROM bootcamp.nba_game_details_dedup AS dedup
    JOIN bootcamp.nba_games AS games
        ON games.game_id = dedup.game_id
),
streak_wins_over_90 AS (
    -- Calculate the rolling sum of wins over the last 90 games for each team
    SELECT *,
        SUM(match_won) OVER (PARTITION BY team ORDER BY game_date ASC ROWS BETWEEN 89 PRECEDING AND CURRENT ROW) AS ninety_days_wins_streak
    FROM nba_games_data
)
SELECT 
    team,
    MAX(ninety_days_wins_streak) AS max_wins_streak,
    MAX_BY(game_date, ninety_days_wins_streak) AS end_streak_date
FROM streak_wins_over_90
GROUP BY team
ORDER BY max_wins_streak DESC
LIMIT 1