WITH
    combined AS (
        SELECT
            gd.player_name,
            gd.team_abbreviation,
            g.season,
            -- Did not exaust all possible fields, this is just for illustration
            CAST(gd.fgm AS DOUBLE) AS fgm,
            CAST(gd.fga AS DOUBLE) AS fga,
            CAST(gd.fg3m AS DOUBLE) AS fg3m,
            CAST(gd.fg3a AS DOUBLE) AS fg3a,
            CAST(gd.ftm AS DOUBLE) AS ftm,
            CAST(gd.fta AS DOUBLE) AS fta,
            CAST(gd.oreb AS DOUBLE) AS oreb,
            CAST(gd.dreb AS DOUBLE) AS dreb,
            CAST(gd.reb AS DOUBLE) AS reb,
            CAST(gd.ast AS DOUBLE) AS ast,
            CAST(gd.stl AS DOUBLE) AS stl,
            CAST(gd.blk AS DOUBLE) AS blk,
            CAST(gd.to AS DOUBLE) AS to,
            CAST(gd.pf AS DOUBLE) AS pf,
            CAST(gd.pts AS DOUBLE) AS pts,
            CAST(gd.plus_minus AS DOUBLE) AS plus_minus
        FROM
            bootcamp.nba_games g
            JOIN bootcamp.nba_game_details gd ON g.game_id = gd.game_id
    )
SELECT
    COALESCE(player_name, '(Overall)') as player_name,
    COALESCE(team_abbreviation, '(overall)') as team_abbreviation,
    COALESCE(CAST(season AS VARCHAR), '(overall)') as season,
    COUNT(1) as number_of_games,
    -- I chose to sum the fields, but any other aggregation could have been used
    SUM(fgm) AS total_fgm,
    SUM(fga) AS total_fga,
    SUM(fg3m) AS total_fg3m,
    SUM(fg3a) AS total_fg3a,
    SUM(ftm) AS total_ftm,
    SUM(fta) AS total_fta,
    SUM(oreb) AS total_oreb,
    SUM(dreb) AS total_dreb,
    SUM(reb) AS total_reb,
    SUM(ast) AS total_ast,
    SUM(stl) AS total_stl,
    SUM(blk) AS total_blk,
    SUM(to) AS total_to,
    SUM(pf) AS total_pf,
    SUM(pts) AS total_pts,
    SUM(plus_minus) AS total_plus_minus
FROM
    combined
GROUP BY
    GROUPING SETS (
        (player_name, team_abbreviation),
        (player_name, season),
        (team_abbreviation)
    )