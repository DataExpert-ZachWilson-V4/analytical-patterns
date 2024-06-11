SELECT 
    -- grab the max total point of any player in any season
    MAX(total_points) as total_points_in_season,
    -- Player name that's associated with the max total points
    MAX_BY(player_name, total_points) as player_name,
    -- Player id that's associated with the max total points
    MAX_BY(player_id, total_points) as player_id,
    -- season that's associated with the max total points
    MAX_BY(season, total_points) as season
FROM 
    hw5_q2
WHERE
    -- since we are only interested in player-season aggregate, set team_id to null
    player_name is not null and season is not null and team_id is null