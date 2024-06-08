WITH
  ranking AS (
    SELECT
      *,
      ROW_NUMBER() OVER (
        PARTITION BY
          game_id,
          team_id,
          player_id
      ) row_num
    FROM
      bootcamp.nba_game_details
  )
, grouped_sets AS (
SELECT
  COALESCE(r.player_name, 'total') AS player_name,
  COALESCE(CAST(r.team_id AS VARCHAR), 'total') AS team_id,
  COALESCE(CAST(nba.season AS VARCHAR), 'total') AS season,
  SUM(r.pts) AS total_points,
  SUM(r.ftm) AS ftm
FROM
  ranking r
INNER JOIN bootcamp.nba_games nba ON r.game_id = nba.game_id
WHERE
  row_num = 1
GROUP BY
  GROUPING SETS (
    (r.player_name, r.team_id),
    (r.player_name, nba.season),
    (r.team_id),
    ()
  )
)
-- "Which player scored the most points playing for a single team?"
SELECT player_name
FROM (
SELECT player_name
     , team_id
     , total_points
     , ROW_NUMBER() OVER(ORDER BY total_points DESC) AS row_cnt
FROM grouped_sets
WHERE season = 'total'
AND team_id != 'total'
AND player_name != 'total'
)ranked
WHERE row_cnt = 1