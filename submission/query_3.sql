-- Define common table expressions (CTEs)
WITH
  -- CTE to rank players based on their total points scored in a season
  player_rankings AS (
    SELECT
      player_name, -- Player's name
      season, -- Corresponding season
      total_points, -- Total points scored by the player in the season
      DENSE_RANK() OVER (
        ORDER BY
          total_points DESC -- Rank players by total points in descending order
      ) AS ranking -- Assign rank based on total points scored
    FROM
      datademonslayer.grouping_sets -- Source table is updated to datademonslayer.grouping_sets
    WHERE
      player_name IS NOT NULL -- Exclude records without player names
      AND team_city <> 'Not Available' -- Exclude records where the team is listed as 'Not Available'
  )

-- Select players with the highest rank (top scorers) from the rankings
SELECT
  player_name, -- Player's name
  season, -- Season of performance
  total_points -- Points scored
FROM
  player_rankings -- From the rankings CTE
WHERE
  ranking = 1 -- Filter to include only top scorers in each season