-- Define common table expressions (CTEs)
WITH
  -- CTE to rank players based on their points within each season
  data_rank AS (
    SELECT
      player_name, -- Select player name
      season, -- Select season
      points, -- Select points scored
      DENSE_RANK() OVER (
        ORDER BY
          points DESC -- Rank players by points in descending order
      ) AS rnk -- Assign rank based on points
    FROM
      RaviT.grouping_sets -- Source table is RaviT.grouping_sets
    WHERE
      player_name IS NOT NULL -- Exclude records where player_name is NULL
      AND season IS NOT NULL -- Exclude records where season is NULL
  )

-- Select players with the highest rank (top scorers)
SELECT
  player_name, -- Select player name
  season, -- Select season
  points -- Select points scored
FROM
  data_rank -- From the ranked data CTE
WHERE
  rnk = 1 -- Filter to include only players with rank 1 (highest points)
