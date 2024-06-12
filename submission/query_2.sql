-- Create or replace the table RaviT.grouping_sets
CREATE OR REPLACE TABLE RaviT.grouping_sets AS

-- Define common table expressions (CTEs)
WITH
  -- CTE to combine game details and game information
  combined AS (
    SELECT
      player_name AS player_name, -- Select player name
      COALESCE(team_city, 'N/A') AS team, -- Use team city, or 'N/A' if null
      season, -- Select season
      SUM(gd.pts) points, -- Sum of points scored by the player
      SUM(
        CASE
          WHEN (
            gd.team_id = g.home_team_id -- Check if team is home team
            AND home_team_wins = 1 -- Check if home team won
          )
          OR (
            gd.team_id = g.visitor_team_id -- Check if team is visitor team
            AND home_team_wins = 0 -- Check if visitor team won
          ) THEN 1 -- Increment count if the team won
          ELSE 0 -- Otherwise, do not increment
        END
      ) AS total_games_won -- Sum of games won
    FROM
      bootcamp.nba_game_details_dedup gd -- From the game details table
      JOIN bootcamp.nba_games g ON gd.game_id = g.game_id -- Join with games table on game_id
    GROUP BY
      -- Group by sets to calculate aggregates at different levels
      GROUPING SETS (
        (player_name, team_city), -- Group by player and team
        (player_name, season), -- Group by player and season
        (team_city) -- Group by team
      )
  )

-- Select all columns from the combined CTE for the final table
SELECT
  *
FROM
  combined
