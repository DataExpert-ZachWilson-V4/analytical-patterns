--Query that defines players wiith the most points playing for a single team
SELECT
    player_name,
    team_abbreviation,
    total_points
FROM
    amaliah21315.nba_game_details_grouped
WHERE
    grouping_category = 'player_team' -- only selects sets of player and teams, excludes other grouped sets
    AND total_points IS NOT NULL --excludes unnecessary records where there are no points
ORDER BY
    total_points DESC
LIMIT 1 -- selects the top player 