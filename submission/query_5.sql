--Query that defines teams that won the most game
SELECT
    team_abbreviation,
    total_points
FROM
    amaliah21315.nba_game_details_grouped
WHERE
    (grouping_category = 'team_only') -- selects category by teams only
ORDER BY
    total_points DESC 
    -- LIMIT 1 -- select the top team