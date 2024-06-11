SELECT 
    -- get the max total points for any player-team combo where season is null
    MAX(total_points) as total_points,
    -- Player name that's associated with the max total points
    MAX_BY(player_name, total_points) as player_name,
    -- Player id that's associated with the max total points
    MAX_BY(player_id, total_points) as player_id,
    -- team of the player that's associated with the max total points
    MAX_BY(team_id, total_points) as team_id
FROM 
    hw5_q2
WHERE
    -- Since we are only interested in the player-team aggregate, we should have season set to null in grouping sets
    player_id is not null and team_id is not null and season is null