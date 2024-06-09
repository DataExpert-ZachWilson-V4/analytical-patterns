SELECT
    MAX_BY(player_name, total_points) as player_name,
    MAX_BY(team_abbreviation, total_points) as team_name,
    MAX(total_points) as max_total_points
FROM
    bgar.nba_grouping_sets
WHERE
    level_id = 'player and team'
    AND total_points IS NOT NULL
