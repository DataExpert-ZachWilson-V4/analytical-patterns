SELECT 
    season,
    player_id,
    player_name, 
    nickname,
    team_id,
    team_abbreviation,
    team_city,
    SUM(
        CASE 
            WHEN POSITION(':' IN min) > 0 THEN 
                (CAST(SUBSTRING(min, 1, POSITION(':' IN min) - 1) AS DOUBLE) * 60) +
                CAST(SUBSTRING(min, POSITION(':' IN min) + 1) AS DOUBLE)
            ELSE 
                CAST(min AS DOUBLE) * 60
        END
    ) AS total_seconds_played,
    SUM(fgm) AS total_field_goals_made,
    SUM(fga) AS total_field_goals_attempted,
    AVG(fg_pct) AS avg_field_goal_percentage,
    SUM(fg3m) AS total_three_pointers_made,
    SUM(fg3a) AS total_three_pointers_attempted,
    AVG(fg3_pct) AS avg_three_point_percentage,
    SUM(ftm) AS total_free_throws_made,
    SUM(fta) AS total_free_throws_attempted,
    AVG(ft_pct) AS avg_free_throw_percentage,
    SUM(oreb) AS total_offensive_rebounds,
    SUM(dreb) AS total_defensive_rebounds,
    SUM(reb) AS total_rebounds,
    SUM(ast) AS total_assists,
    SUM(stl) AS total_steals,
    SUM(blk) AS total_blocks,
    SUM(to) AS total_turnovers,
    SUM(pf) AS total_personal_fouls,
    SUM(pts) AS total_points,
    SUM(plus_minus) AS total_plus_minus
FROM 
    bootcamp.nba_game_details
LEFT JOIN bootcamp.nba_games using(game_id)
GROUP BY 
    GROUPING SETS (
        (player_id, player_name, nickname, team_id, team_abbreviation, team_city),
        (player_id, player_name, nickname, season),
        (team_id, team_abbreviation, team_city)
    )

