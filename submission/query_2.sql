WITH combined AS (
  SELECT
    COALESCE(CAST(ng.season AS VARCHAR), 'N/A') AS season,
  	COALESCE(CAST(ng.game_id AS VARCHAR), 'N/A') AS game,
  	COALESCE(CAST(ngd.team_id AS VARCHAR), 'N/A') AS team,
  	COALESCE(CAST(ngd.player_id AS VARCHAR), 'N/A') AS player,
  	ngd.*
  FROM bootcamp.nba_game_details ngd
  LEFT JOIN bootcamp.nba_games ng
    ON ng.game_id = ngd.game_id

)
SELECT
  COALESCE(player, '(overall)') AS player,
  COALESCE(team, '(overall)') AS team,
  COALESCE(season, '(overall)') AS season,
  AVG(CAST(fgm AS DOUBLE)) AS fgm,
  AVG(CAST(fga AS DOUBLE)) AS fga,
  AVG(CAST(fg3m AS DOUBLE)) AS fg3m,
  AVG(CAST(fg3a AS DOUBLE)) AS fg3a,
  AVG(CAST(pts AS DOUBLE)) AS pts
FROM combined
GROUP BY GROUPING SETS (
    (player, team),
    (player, season),
    (team)
)