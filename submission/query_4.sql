WITH grouping_sets as (
    SELECT COALESCE(player_name, 'OVERALL') as player_name,
        COALESCE(team_abbreviation, 'OVERALL') as team_abbreviation,
        COALESCE(CAST(season AS VARCHAR), 'OVERALL') AS season,
        SUM(pts) as pts
    FROM bootcamp.nba_game_details_dedup as game_details
        LEFT JOIN bootcamp.nba_games games ON game_details.game_id = games.game_id
    GROUP BY GROUPING SETS (
            (player_name, team_abbreviation),
            (player_name, season),
            (team_abbreviation)
        )
)
SELECT player_name, season, pts
FROM grouping_sets
WHERE season <> 'OVERALL'
    AND player_name <> 'OVERALL'
    AND team_abbreviation = 'OVERALL'
ORDER BY pts DESC
LIMIT 1
