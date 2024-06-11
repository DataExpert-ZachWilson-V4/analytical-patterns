WITH expanded_seasons AS (
    SELECT
        player_name as playername,
        t.*
    FROM
        bootcamp.nba_players p
    CROSS JOIN UNNEST (seasons) AS t
),
player_stats AS (
    SELECT 
        playername,
        p.season,
        COUNT(DISTINCT d.game_id) as games_played,
        SUM(distinct p.gp) as total_gp,
        SUM(distinct p.pts) as total_pts,
        SUM(distinct p.reb) as total_reb,
        SUM(distinct p.ast) as total_ast,
        team_id,
        team_abbreviation
    FROM expanded_seasons p 
    JOIN bootcamp.nba_game_details d 
        ON p.playername = d.player_name
    GROUP BY 
        playername,
        p.season,
        team_id,
        team_abbreviation
)

SELECT 
    playername,
    season,
    team_id,
    team_abbreviation,
    MAX(total_gp) as gp,
    MAX(total_pts) as pts,
    MAX(total_reb) as reb,
    MAX(total_ast) as ast,
    SUM(games_played) as games_played_per_season
FROM player_stats
GROUP BY
    GROUPING SETS (
        (playername, team_id, team_abbreviation, season),
        (playername, season),
        (team_id, team_abbreviation)
    )
having playername = 'Eric Piatkowski' and season is not null
ORDER BY playername, season, team_id, team_abbreviation
