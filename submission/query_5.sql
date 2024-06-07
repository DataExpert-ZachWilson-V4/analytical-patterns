--Write a query (query_5) to answer: "Which team has won the most games"

  
  WITH base AS (
  
  SELECT 
  d.player_name,
  d.team_city as team,
  g.season,
  d.pts,
  d.pf,
  d.reb,
  d.ast,
  d.team_id,
  g.home_team_id,
  g.home_team_wins,
  g.visitor_team_id
  
  
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
  SUM(ast) AS ast,
  SUM(CASE 
    WHEN (team_id = home_team_id AND home_team_wins = 1) 
        OR (team_id = visitor_team_id AND home_team_wins = 0) 
    THEN 1 ELSE 0 END
  ) AS total_games_won
  
  FROM base

  GROUP BY
     GROUPING SETS(
       (player_name, team),
       (player_name, season),
       (team)
     )
)

SELECT

team,
season,
total_games_won

FROM aggregations
WHERE team != 'Overall'
and season = 'Overall'

ORDER BY pts DESC -- getting first ones

LIMIT 1
