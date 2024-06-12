-- Create or replace the table datademonslayer.grouping_sets
CREATE OR REPLACE TABLE datademonslayer.grouping_sets AS

-- Prepare data aggregation using common table expressions (CTEs)
WITH
  -- CTE to summarize game details by combining player and team information
  game_summary AS (
    SELECT
      gd.player_name AS player_name, -- Use player name from game details
      COALESCE(gd.team_city, 'Not Available') AS team_city, -- Use team city from game details, defaulting to 'Not Available' if null
      season, -- Include season year
      SUM(gd.pts) AS total_points, -- Aggregate total points scored by the player
      SUM(
        CASE
          WHEN (
            gd.team_id = g.home_team_id AND g.home_team_wins = 1 -- Conditions for a home team win
          ) OR (
            gd.team_id = g.visitor_team_id AND g.home_team_wins = 0 -- Conditions for a visiting team win
          ) THEN 1 -- Count as a win
          ELSE 0 -- Do not count as a win
        END
      ) AS games_won -- Count total games won
    FROM
      bootcamp.nba_game_details_dedup gd -- Source table for game details
      JOIN bootcamp.nba_games g ON gd.game_id = g.game_id -- Join with games table using game ID
    GROUP BY
      -- Define grouping sets for aggregate calculations
      GROUPING SETS (
        (player_name, team_city), -- Group by player and team city
        (player_name, season), -- Group by player and season
        (team_city) -- Group only by team city
      )
  )

-- Retrieve data from the game summary for output
SELECT
  *
FROM
  game_summary
