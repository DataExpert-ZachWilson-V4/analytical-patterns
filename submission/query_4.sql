-- Query 4: Which player scored the most points in one season?
-- CTE to calculate total points scored by each player in each season
WITH player_season_points AS (
  SELECT 
    player AS player,         -- Player name
    season,                   -- Season
    SUM(total_pts) AS total_points  -- Total points scored by the player in that season
  FROM sanniepatron.grouping_sets
  WHERE player IS NOT NULL AND season IS NOT NULL  -- Filter out NULL values for player and season
  GROUP BY player, season     -- Group by player and season
),
-- CTE to rank the players by total points scored in a season using DENSE_RANK
ranked_player_season_points AS (
  SELECT 
    player,                   -- Player name
    season,                   -- Season
    total_points,             -- Total points scored by the player in that season
    DENSE_RANK() OVER (ORDER BY total_points DESC) AS rank  -- Rank players by total points in descending order
  FROM player_season_points
)
-- Select the player(s) with the highest total points in a season
SELECT 
  player,                     -- Player name
  season,                     -- Season
  total_points                -- Total points scored by the player in that season
FROM ranked_player_season_points
WHERE rank = 1               -- Filter to get the player(s) with the highest rank (most points scored in a season)