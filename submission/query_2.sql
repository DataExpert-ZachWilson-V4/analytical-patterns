WITH
  ranking AS (
    SELECT
      *,
      -- dedupe table by partitioning based on game_id, player_id and team_id
      ROW_NUMBER() OVER (
        PARTITION BY
          game_id,
          team_id,
          player_id
      ) row_num
    FROM
      bootcamp.nba_game_details
  )
SELECT
-- replace null which represent a overall level in the grouping sets with "total"
  COALESCE(r.player_name, 'total') AS player_name,
  COALESCE(CAST(r.team_id AS VARCHAR), 'total') AS team_id,
  COALESCE(CAST(nba.season AS VARCHAR), 'total') AS season,
  SUM(r.pts) AS total_points,
  SUM(r.ftm) AS ftm
FROM
  ranking r
  -- join deduped nba game details with nba_games table to get measures
INNER JOIN bootcamp.nba_games nba ON r.game_id = nba.game_id
WHERE
  row_num = 1
GROUP BY
-- use grouping sets to create levels of groups
  GROUPING SETS (
    -- group by player and team
    (r.player_name, r.team_id),
    -- group by player and season
    (r.player_name, nba.season),
    -- group by team only
    (r.team_id),
    -- create an overall group
    ()
  )