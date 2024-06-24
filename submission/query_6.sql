-- Deduplicate game details
WITH nba_game_details_deduped AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY game_id, team_id, player_id) row_number
    FROM bootcamp.nba_game_details
),

-- Combine game details with game results
combined AS (
    SELECT
        gd.game_id,
        gd.team_abbreviation,
        g.game_date_est,
        CASE 
            WHEN gd.team_id = g.home_team_id AND g.home_team_wins = 1 THEN 1   
            WHEN gd.team_id = g.visitor_team_id AND g.home_team_wins = 0 THEN 1 
            ELSE 0
        END AS team_won_game
    FROM bootcamp.nba_games g 
    JOIN nba_game_details_deduped gd ON g.game_id = gd.game_id AND gd.row_number = 1
    WHERE g.game_date_est IS NOT NULL
),

-- Calculate total games won in a 90-game stretch
games_won_90_game_stretch AS (
    SELECT *,
        SUM(team_won_game) OVER (
            PARTITION BY team_abbreviation ORDER BY game_date_est 
            ROWS BETWEEN 89 PRECEDING AND CURRENT ROW
        ) AS games_won
    FROM combined
)

-- Get maximum games won in a 90-game stretch for each team
SELECT team_abbreviation, MAX(games_won) as max_games_won_90_game_stretch
FROM games_won_90_game_stretch
GROUP BY team_abbreviation
ORDER BY max_games_won_90_game_stretch DESC
