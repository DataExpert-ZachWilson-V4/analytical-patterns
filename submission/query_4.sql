--Query that defines players wiith the most points playing for a single season
SELECT
    player_name,
    season,
    total_points
FROM
    amaliah21315.nba_game_details_grouped
WHERE
    (
        grouping_category = 'player_season'
    ) -- includes only grouped sets of player and season
ORDER BY
    total_points DESC 
    -- LIMIT 1 -- selects the top player for a season