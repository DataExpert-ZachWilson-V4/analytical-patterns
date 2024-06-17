/*
A query that uses `GROUPING SETS` to perform aggregations of the `nba_game_details` data. 
Create slices that aggregate along the following combinations of dimensions:
  - player and team
  - player and season
  - team
*/

WITH game_details AS (

  SELECT
    COALESCE(CAST(g.season AS VARCHAR), 'NA') AS season,
  	COALESCE(CAST(g.game_id AS VARCHAR), 'NA') AS game,
  	COALESCE(CAST(gd.team_id AS VARCHAR), 'NA') AS team,
  	COALESCE(CAST(gd.player_id AS VARCHAR), 'NA') AS player,
  	gd.*
  FROM bootcamp.nba_game_details gd
  LEFT JOIN bootcamp.nba_games g
    ON g.game_id = gd.game_id

)
SELECT
  COALESCE(player, 'Overall') AS player,
  COALESCE(team, 'Overall') AS team,
  COALESCE(season, 'Overall') AS season,
  AVG(CAST(fgm AS DOUBLE)) AS fgm_pg,
  AVG(CAST(fga AS DOUBLE)) AS fga_pg,
  AVG(CAST(fg3m AS DOUBLE)) AS fg3m_pg,
  AVG(CAST(fg3a AS DOUBLE)) AS fg3a_pg,
  AVG(CAST(ftm AS DOUBLE)) AS ftm_pg,
  AVG(CAST(fta AS DOUBLE)) AS fta_pg,
  AVG(CAST(oreb AS DOUBLE)) AS oreb_pg,
  AVG(CAST(dreb AS DOUBLE)) AS dreb_pg,
  AVG(CAST(reb AS DOUBLE)) AS reb_pg,
  AVG(CAST(ast AS DOUBLE)) AS ast_pg,
  AVG(CAST(stl AS DOUBLE)) AS stl_pg,
  AVG(CAST(blk AS DOUBLE)) AS blk_pg,
  AVG(CAST(to AS DOUBLE)) AS to_pg,
  AVG(CAST(pf AS DOUBLE)) AS pf_pg,
  AVG(CAST(pts AS DOUBLE)) AS pts_pg
FROM game_details
GROUP BY GROUPING SETS (
    (player, team),
    (player, season),
    (team)
)