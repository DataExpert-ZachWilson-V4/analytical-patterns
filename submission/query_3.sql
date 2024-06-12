WITH player_team AS(
    SELECT 
        player_name, 
        team_abbreviation,
        SUM(points) as points
    FROM supreethkabbin.nba_game_grouping
    WHERE aggregation_level = 'player_and_team'
    GROUP BY 
        player_name,
        team_abbreviation
    )
SELECT player_name
FROM player_team
WHERE points = (
        SELECT 
            MAX(points) 
        FROM player_team
)