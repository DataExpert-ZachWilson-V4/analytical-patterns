-- query 3 the player who scored most points for a team

SELECT
    team,
    player_name, 
    points
FROM aayushi.nba_grouping_sets
WHERE 
    agg_data = 'player_and_team' AND points > 0 --using grouping sets to filter 
ORDER BY points DESC 
LIMIT 1