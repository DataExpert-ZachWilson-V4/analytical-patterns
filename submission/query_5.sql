SELECT 
    -- get the max total wins by any team
    MAX(total_wins) as total_wins,
    -- get the team associated with the max total wins
    MAX_BY(team_id, total_points) as team_id
FROM 
    hw5_q2
WHERE
    -- since we are only interested in team level aggregate, set all other grouping sets to null
    player_id is null and season is null and team_id is not null