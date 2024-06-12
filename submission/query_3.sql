WITH grouping_sets as (
    SELECT COALESCE(player_name, 'OVERALL') as player_name,
        COALESCE(team_abbreviation, 'OVERALL') as team_abbreviation,
        COALESCE(CAST(season AS VARCHAR), 'OVERALL') AS season,
        SUM(fgm) as fgm,
        SUM(fga) as fga,
        CASE
            WHEN SUM(fga) > 0 THEN SUM(fgm) / SUM(fga)
        END AS fgpct,
        SUM(fg3m) as fg3m,
        SUM(fg3a) as fg3a,
        CASE
            WHEN SUM(fg3a) > 0 THEN SUM(fg3m) / SUM(fg3a)
        END AS fg3pct,
        SUM(ftm) as ftm,
        SUM(fta) as fta,
        CASE
            WHEN SUM(fta) > 0 THEN SUM(ftm) / SUM(fta)
        END AS ftpct,
        SUM(oreb) as oreb,
        SUM(dreb) as dreb,
        SUM(reb) as reb,
        SUM(ast) as ast,
        SUM(stl) as stl,
        SUM(blk) as blk,
        SUM(to) as to,
        SUM(pf) as pf,
        SUM(pts) as pts,
        SUM(plus_minus) as plus_minus
    FROM bootcamp.nba_game_details_dedup as game_details
        LEFT JOIN bootcamp.nba_games games ON game_details.game_id = games.game_id
    GROUP BY GROUPING SETS (
            (player_name, team_abbreviation),
            (player_name, season),
            (team_abbreviation)
        )
)
SELECT player_name
FROM grouping_sets
WHERE season = 'OVERALL'
    AND player_name <> 'OVERALL'
    AND team_abbreviation <> 'OVERALL'
ORDER BY pts DESC
LIMIT 1
