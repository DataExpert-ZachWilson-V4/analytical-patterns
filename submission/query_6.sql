-- What is the most games a single team has won in a given 90-game stretch

WITH 
    -- add a row number to each row in nba_game_details to be used for deduping
    nba_game_details_deduped AS (
        SELECT 
            *,
            ROW_NUMBER() OVER (PARTITION BY game_id, team_id, player_id) rn 
        FROM bootcamp.nba_game_details
    ),

    combined AS (
        SELECT
            gd.game_id,
            gd.team_id,
            g.game_date_est,
            MAX(CASE 
                WHEN gd.team_id = g.home_team_id AND g.home_team_wins = 1 THEN 1    -- if tean_id is same as home_team_id and home_team_wins is 1, then team won
                WHEN gd.team_id = g.visitor_team_id AND g.home_team_wins = 0 THEN 1 -- if team_id is same as visitor_team_id and home_team_wins is 0, then team won
                ELSE 0
            END) AS dim_team_won
        FROM bootcamp.nba_games g 
        JOIN nba_game_details_deduped gd ON g.game_id = gd.game_id AND gd.rn = 1
        GROUP BY gd.game_id, gd.team_id,  g.game_date_est
    ),
    
    streaks AS (
      SELECT *,
        SUM(dim_team_won) OVER (PARTITION BY team_id ORDER BY game_date_est ROWS BETWEEN 89 PRECEDING AND CURRENT ROW) AS win_streak_for_90_games
      FROM combined
    )
    
  SELECT MAX(win_streak_for_90_games) as max_games_won_90_day_stretch
  FROM streaks
  