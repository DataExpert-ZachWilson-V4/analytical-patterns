-- Define common table expressions (CTEs)
WITH
  -- CTE to rank teams based on the total number of games won in each season
  team_rankings AS (
    SELECT
      team_city as team, -- Use team city as team name
      games_won as total_games_won, -- Total games won by the team
      DENSE_RANK() OVER (
        ORDER BY games_won DESC -- Rank teams by total games won in descending order
      ) AS rank -- Assign rank based on total games won
    FROM
      datademonslayer.grouping_sets -- source table datademonslayer.grouping_sets
    WHERE
      team_city <> 'Not Available' -- Exclude records where team city is 'Not Available'
  )

-- Select teams with the highest rank (most games won)
SELECT
  team, -- Selected team
  total_games_won, -- Total games won by the team
  rank -- Rank of the team based on games won
FROM
  team_rankings -- From the ranked data CTE
WHERE
  rank = 1 -- Filter to include only teams with rank 1 (most games won)