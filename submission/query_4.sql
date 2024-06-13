-- query 4 player who scored most points in a season

SELECT
    season,
    player_name,
    points
FROM aayushi.nba_grouping_sets 
WHERE
    agg_data = 'player_and_season' AND points > 0 --using grouping sets to filter 
ORDER BY points DESC 
LIMIT 1