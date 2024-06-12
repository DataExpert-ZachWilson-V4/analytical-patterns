-- CTE to record game data for each date
WITH distinct_game_data AS (
    SELECT 
        DISTINCT game_date_est, 
        game_id,
        home_team_id,
        visitor_team_id,
        home_team_wins
    FROM bootcamp.nba_games
   
),
-- CTE to record data combined over deduped data for each team
combined AS (
    SELECT 
        game_date_est AS game_date,
        home_team_id AS team_id,
        home_team_wins AS game_win
    FROM distinct_game_data
        
    union
    
    SELECT 
        game_date_est AS game_date,
        home_team_id AS team_id,
    CASE 
        WHEN home_team_wins = 0 THEN 1
        WHEN home_team_wins = 1 THEN 0 
    end AS game_win
    FROM distinct_game_data
),
-- CTE to record total wins OVER a 90 game sliding window
over_90_game_sliding AS (
    SELECT 
        team_id, 
        game_date - INTERVAL '90' DAY AS starting,
        game_date AS ending, 
        SUM(game_win) OVER (partition by team_id order by game_date ROWS BETWEEN 89 PRECEDING AND CURRENT ROW) AS total_wins
    FROM combined
)
SELECT 
    MAX_BY(team_id, total_wins) AS team_id,
    MAX(total_wins) AS total_game_wins
FROM over_90_game_sliding
