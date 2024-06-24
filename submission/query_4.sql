--Query that defines players wiith the most points playing for a single season
SELECT
    player_name,
    season,
    total_points
FROM
    amaliah21315.nba_game_details_grouped
WHERE
    grouping_category = 'player_season' -- includes only grouped sets of player and seasonssss
    AND total_points IS NOT NULL --excludes unnecessary records where there are no points
ORDER BY
    total_points DESC
LIMIT 1 -- limits the output to the player with the most points in a single season 