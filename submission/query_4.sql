-- Define common table expressions (CTEs)
WITH
  -- CTE to rank players based on their total points scored within each season
  season_rankings AS (
    SELECT
      player_name, -- Player's name
      season, -- Corresponding season
      total_points, -- Total points scored by the player in the season
      DENSE_RANK() OVER (
        PARTITION BY season -- Partition ranking by season
        ORDER BY
          total_points DESC -- Rank players by total points in descending order within each season
      ) AS rank -- Assign rank based on points within the season
    FROM
      datademonslayer.grouping_sets -- Updated source table to datademonslayer.grouping_sets
    WHERE
      player_name IS NOT NULL -- Exclude records without player names
      AND season IS NOT NULL -- Exclude records without season information
  )

-- Select players who ranked highest in their respective seasons (top scorers)
SELECT
  player_name, -- Player's name
  season, -- Season of performance
  total_points -- Points scored during the season
FROM
  season_rankings -- From the rankings CTE
WHERE
  rank = 1 -- Filter to include only the top scorer in each season