--Query that defines teams that won the most game
SELECT
    team_abbreviation,
    total_points
FROM
    amaliah21315.nba_game_details_grouped
WHERE
    grouping_category = 'team_only' -- selects category by teams only
    AND total_points IS NOT NULL --excludes unnecessary records where there are no points
ORDER BY
    total_points DESC
LIMIT 1 -- select the top team