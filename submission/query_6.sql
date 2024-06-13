/*
Write a query (query_6) that uses window functions 
on nba_game_details to answer the question: 
"What is the most games a single team has won in a given 90-game stretch?"
*/

WITH nba_game_details_deduped AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY game_id, team_id, player_id) row_number
    FROM bootcamp.nba_game_details
),

combined AS (
    SELECT
        gd.game_id,
        gd.team_id,
        gd.team_abbreviation,
        g.game_date_est,
        MAX(CASE 
            WHEN gd.team_id = g.home_team_id AND g.home_team_wins = 1 THEN 1   
            WHEN gd.team_id = g.visitor_team_id AND g.home_team_wins = 0 THEN 1 
            ELSE 0
        END) AS team_won_game
    FROM bootcamp.nba_games g 
    JOIN nba_game_details_deduped gd ON g.game_id = gd.game_id AND gd.row_number = 1
    GROUP BY 
        gd.game_id, 
        gd.team_id,
        gd.team_abbreviation,
        g.game_date_est
    ),

streaks AS (
    SELECT *,
        SUM(team_won_game) OVER (
            PARTITION BY team_id ORDER BY game_date_est 
            ROWS BETWEEN 89 PRECEDING AND CURRENT ROW
        ) AS win_streak_90_games
    FROM combined
)

SELECT team_abbreviation, MAX(win_streak_90_games) as max_games_won_90_day_stretch
FROM streaks
GROUP BY team_id, team_abbreviation
ORDER BY max_games_won_90_day_stretch DESC
LIMIT 1