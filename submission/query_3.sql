-- "Which player scored the most points playing for a single team?"

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
  ),
grouped AS (
SELECT
  COALESCE(player, '(overall)') AS player,
  COALESCE(team, '(overall)') AS team,
  COALESCE(season, '(overall)') AS season,
  COUNT(DISTINCT game) AS games,
  AVG(CAST(pts AS DOUBLE)) AS pts
FROM combined
GROUP BY GROUPING SETS (
    (player, team),
    (player, season),
    (team)
    )
)

SELECT player
FROM grouped
WHERE player != '(overall)' AND team != '(overall)'
ORDER BY (pts * games) DESC
LIMIT 1