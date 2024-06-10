SELECT
    -- The Player Name
    coalesce(gd.player_name, '(overall)') AS player_name,
    -- The Team Name 
    coalesce(gd.team_abbreviation, '(overall)') AS team,
    -- Season
    coalesce(g.season, -1) AS season,
    -- Total Points
    SUM(pts) AS total_pts,
    -- Total Games
    COUNT(DISTINCT g.game_id) as total_games
FROM bootcamp.nba_game_details gd
JOIN bootcamp.nba_games g ON g.game_id = gd.game_id
GROUP BY GROUPING SETS (
    -- Grouping sets to get the aggregates
    (gd.player_name, gd.team_abbreviation),
    (gd.player_name, g.season),
    (gd.team_abbreviation)
)
