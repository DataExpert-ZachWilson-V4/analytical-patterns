-- Define common table expressions (CTEs)

WITH
  -- CTE to rank teams based on the total number of games won
  data_rnk AS (
    SELECT
      team, -- Select team
      total_games_won, -- Select total games won by the team
      DENSE_RANK() OVER (
        ORDER BY total_games_won DESC -- Rank teams by total games won in descending order
      ) AS rnk -- Assign rank based on total games won
    FROM
      RaviT.grouping_sets -- Source table is RaviT.grouping_sets
    WHERE
      team <> 'N/A' -- Exclude records where team is 'N/A'
  )

-- Select teams with the highest rank (most games won)
SELECT
  team, -- Select team
  total_games_won, -- Select total games won
  rnk -- Select rank
FROM
  data_rnk -- From the ranked data CTE
WHERE
  rnk = 1 -- Filter to include only teams with rank 1 (most games won)
