-- Write a query (query_2) that uses GROUPING SETS to perform aggregations of the nba_game_details data. Create slices that aggregate along the following combinations of dimensions:

-- player and team
-- player and season
-- team

  
WITH base AS (

 -- joining nba_games to get season
 -- we do this at this stage to avoid issues with the coalesce in the cte below
  
  
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
  
)
  
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
