WITH nba_games_data AS (
SELECT DISTINCT -- Distinct helps to get data to "game", "team" granularity.  
       GD.game_id, -- Because data was in "player", "game", "team" granularity.
       GD.team_abbreviation,
       IF(
       (GD.team_id = G.home_team_id AND G.home_team_wins = 1)
       OR (GD.team_id = G.visitor_team_id AND G.home_team_wins = 0)
     , 1, 0) AS game_won, -- Formula to get if a specific team won or not.
       G.game_date_est AS game_date -- Retrieve game date from "nba_games" table
FROM bootcamp.nba_game_details_dedup AS GD
JOIN bootcamp.nba_games AS G ON G.game_id = GD.game_id
),
streak AS (
  SELECT *,
        SUM(game_won) OVER (PARTITION BY team_abbreviation ORDER BY game_date ASC ROWS BETWEEN 90 PRECEDING AND CURRENT ROW) AS ninety_days_streak
        -- Rolling sum of the won games in the last 90 games
  FROM nba_games_data
)
SELECT 
  team_abbreviation,
  MAX_BY(game_date,ninety_days_streak) AS end_stretch_date, -- Returns the date end of the 90 games stretch with the biggest number of won games.
  MAX(ninety_days_streak) AS n_won_90_games_stretch -- Returns the biggest number of won games in 90 games stretch.
FROM streak
GROUP BY 1
ORDER BY 3 DESC