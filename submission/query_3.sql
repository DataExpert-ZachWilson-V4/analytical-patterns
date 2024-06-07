
--Write a query (query_3) to answer: "Which player scored the most points playing for a single team?"


  
  WITH base AS (
  
  
  SELECT 
  d.player_name,
  d.team_city as team,
  g.season,
  d.pts,
  d.pf,
  d.reb,
  d.ast
  
  FROM bootcamp.nba_game_details_dedup AS d
  LEFT JOIN bootcamp.nba_games AS g
  ON d.game_id = g.game_id
  
  ),
  
  aggregations AS (

  SELECT

  COALESCE(player_name ,'Overall') as player_name,
  COALESCE(team, 'Overall') as team,
  COALESCE(CAST(season AS VARCHAR), 'Overall') as season,
  SUM(pts) AS pts,
  SUM(pf) AS pt,
  SUM(reb) AS reb,
  SUM(ast) AS ast
  
  FROM base

  GROUP BY GROUPING SETS(
       (player_name, team),
       (player_name, season),
       (team)
     )
)

SELECT

player_name,
team,
pts

FROM aggregations
WHERE season = 'Overall' -- getting total points across all seasons
AND player_name != 'Overall'

ORDER BY pts DESC
LIMIT 1
