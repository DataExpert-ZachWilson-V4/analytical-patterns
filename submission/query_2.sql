-- Create or replace table sanniepatron.grouping_sets using CTE for modular query
CREATE OR REPLACE TABLE sanniepatron.grouping_sets AS
WITH nba_games AS (
  -- Select and aggregate data from nba_game_details and nba_games tables
  SELECT 
    player_name,
    COALESCE(team_city, 'N/A') AS team_city,  -- Replace NULL team_city with 'N/A'
    season,
    SUM(pts) AS total_pts,  -- Sum of points scored by each player
    SUM(
      CASE
        WHEN (a.team_id = b.home_team_id AND home_team_wins = 1) 
        OR (a.team_id = b.visitor_team_id AND home_team_wins = 0) THEN 1
        ELSE 0
      END 
    ) AS total_games_won  -- Count of games won by each player
  FROM 
    bootcamp.nba_game_details a
  JOIN 
    bootcamp.nba_games b
  ON 
    a.game_id = b.game_id
  GROUP BY 
    GROUPING SETS (
      (player_name, team_city),  -- Group by player_name and team_city
      (player_name, season),     -- Group by player_name and season
      (team_city)                -- Group by team_city
    )
)

-- Final select to insert data into the table
SELECT 
  player_name AS player,    -- Rename player_name to player
  team_city AS team,        -- Rename team_city to team
  season,
  total_pts,
  total_games_won
FROM 
  nba_games