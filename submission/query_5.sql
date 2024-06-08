SELECT
    team,
    wins
FROM
    videet.nba_grouping_sets
    -- Only include rows where the data represents a single team, and where wins are available
WHERE
    aggregation_level = 'team'
    AND points IS NOT NULL
    -- Sort the rows in descending order based on the points to bring the highest scorer to the top
ORDER BY
    points DESC
    -- Return only the top scoring record
LIMIT
    1 -- the top team is Golden State Warriors