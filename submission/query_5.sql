-- "Which team has won the most games"

WITH combined AS (
  SELECT
    COALESCE(CAST(ng.season AS VARCHAR), 'N/A') AS season,
  	COALESCE(CAST(ng.game_id AS VARCHAR), 'N/A') AS game,
  	COALESCE(CAST(ngd.team_id AS VARCHAR), 'N/A') AS team,
  	COALESCE(CAST(ngd.player_id AS VARCHAR), 'N/A') AS player,
  	ng.home_team_wins,
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
  COUNT(DISTINCT IF(home_team_wins=1, game)) AS nb_of_wins
FROM combined
GROUP BY GROUPING SETS (
    (player, team),
    (player, season),
    (team)
    )
)

SELECT team
FROM grouped
WHERE team != '(overall)'
ORDER BY nb_of_wins DESC
LIMIT 1