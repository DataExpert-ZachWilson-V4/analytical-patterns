SELECT
    player_name,
    team,
    points
FROM
    videet.nba_grouping_sets
    -- Only include rows where the data represents a combination of a single player and a single team, and where points are available
WHERE
    aggregation_level = 'player_plus_team'
    AND points IS NOT NULL
    -- Sort the rows in descending order based on the points to bring the highest scorer to the top
ORDER BY
    points DESC
    -- Return only the top scoring record
LIMIT
    1 -- the top player is LeBron James
