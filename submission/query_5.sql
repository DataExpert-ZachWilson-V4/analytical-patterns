with nba_game_details_agg as(
SELECT 
COALESCE(gd.player_name, 'overall') AS player, 
COALESCE(gd.team_abbreviation, 'overall') AS team,
COALESCE( CAST(g.season AS VARCHAR), 'overall') AS season,
CASE WHEN grouping(gd.player_name, gd.team_abbreviation) = 0 THEN 'player-team'
     WHEN grouping(gd.player_name, g.season) = 0 THEN 'player-season'
     WHEN grouping(gd.team_abbreviation) = 0 THEN 'team' 
END AS grouping_type,
SUM(pts) as total_points,
SUM(case when gd.team_id = g.home_team_id and home_team_wins = 1 then 1
         when gd.team_id = g.visitor_team_id and home_team_wins = 0 then 1 
   else 0 end) as total_wins
FROM (select distinct game_id, team_id, player_name, team_abbreviation,pts from bootcamp.nba_game_details) gd 
JOIN bootcamp.nba_games g on gd.game_id = g.game_id 
GROUP BY
  GROUPING SETS (
    (player_name, team_abbreviation),
    (player_name, season),
    (team_abbreviation)
  )
 ) 
select * from nba_game_details_agg
where grouping_type = 'team'
order by total_wins desc
limit 1
