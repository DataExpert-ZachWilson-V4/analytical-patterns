WITH grouping_sets as (
    SELECT COALESCE(player_name, 'OVERALL') as player_name,
        COALESCE(team_abbreviation, 'OVERALL') as team_abbreviation,
        COALESCE(CAST(season AS VARCHAR), 'OVERALL') AS season,
        SUM(
            CASE
                WHEN game_details.team_id = games.team_id_home
                AND games.home_team_wins = 1 THEN 1
                ELSE 0
            END
        ) AS team_won,
        SUM(pts) as pts
    FROM bootcamp.nba_game_details_dedup as game_details
        LEFT JOIN bootcamp.nba_games games ON game_details.game_id = games.game_id
    GROUP BY GROUPING SETS (
            (player_name, team_abbreviation),
            (player_name, season),
            (team_abbreviation)
        )
)
SELECT team_abbreviation
FROM grouping_sets
WHERE season = 'OVERALL'
    AND player_name = 'OVERALL'
    AND team_abbreviation <> 'OVERALL'
ORDER BY team_won DESC
LIMIT 1
