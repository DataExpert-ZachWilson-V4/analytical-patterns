SELECT d.game_id,
    d.player_name,
    d.team_abbreviation,
    g.season,
    -- find max pts done by groups
    SUM(d.pts) as total_points,
    -- find the winner team for the game
    MAX(
        CASE
            WHEN g.home_team_id = d.team_id
            AND g.home_team_wins = 1 THEN d.team_abbreviation
            WHEN g.visitor_team_id = d.team_id
            AND g.home_team_wins = 0 THEN d.team_abbreviation
        END
    ) AS winner
FROM bootcamp.nba_game_details d
    JOIN bootcamp.nba_games g ON d.game_id = g.game_id
    -- set grouping set
GROUP BY GROUPING SETS(
        (d.player_name, d.team_abbreviation),
        (d.player_name, g.season),
        (d.game_id, d.team_abbreviation)
    )