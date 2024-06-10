--"How many games in a row did LeBron James score over 10 points a game?"

WITH
 nba_game_details_JamesLebron AS (
   SELECT game_id,
     player_name,
     team_id,
     team_abbreviation,
     SUM(pts) AS total_points
   FROM bootcamp.nba_game_details
   WHERE player_name = 'LeBron James'
   GROUP BY game_id, team_id, team_abbreviation, player_name
 ),
 
combined AS (
  SELECT
    gd.game_id,
    gd.player_name,
    g.game_date_est,
    total_points,
    CASE 
       WHEN total_points > 10 THEN 1
       ELSE 0
     END AS over10
  FROM
    bootcamp.nba_games g
    JOIN nba_game_details_JamesLebron gd ON g.game_id = gd.game_id
  ),
    
 lagged AS (
   SELECT game_id,
     player_name,
     game_date_est,
     total_points,
     over10,
     LAG(over10) OVER (ORDER BY game_date_est) AS over10_lagged
     from combined
 ),
 
 streaked AS (
   SELECT *,
     SUM(
       CASE WHEN over10_lagged <> over10 THEN 1 ELSE 0 END) OVER (ORDER BY game_date_est) AS streak_id
     FROM lagged
 ),
  
 streak_length AS (
   SELECT player_name,
     COUNT(1) AS streak_length
     FROM streaked
       GROUP BY player_name, streak_id
       HAVING MAX(over10) = 1
 )
 
 SELECT player_name,
   MAX(streak_length) as num_games_consecutive_over_10
   FROM streak_length
   GROUP BY player_name
