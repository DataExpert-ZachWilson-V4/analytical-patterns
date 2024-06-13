/*
Write a query (query_3) to answer: 
"Which player scored the most points playing for a single team?"
*/

WITH player_and_team AS(
    SELECT 
        player_name, 
        team_abbreviation,
        SUM(total_points) as total_points
    FROM danieldavid.nba_game_details_grouped
    WHERE aggregation_level = 'player_and_team'
    GROUP BY 
        player_name,
        team_abbreviation
    )
SELECT 
    player_name,
    team_abbreviation
FROM player_and_team
WHERE total_points = (
    SELECT MAX(total_points) FROM player_and_team
)