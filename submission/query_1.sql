INSERT INTO
  lsleena.nba_players_state
WITH
  yesterday AS (
    SELECT
      *
    FROM
      lsleena.nba_players_state
    WHERE
      season = 1995
  ),
  today AS (
    SELECT
      player_name,
      is_active,
      current_season
    FROM
      bootcamp.nba_players
    WHERE
      current_season = 1996
      AND is_active
      -- Grouping by because the table has duplicates
    GROUP BY
      player_name,
      is_active,
      current_season
  ),
  aggregated AS (
    SELECT
      COALESCE(y.player_name, t.player_name) AS player_name,
      --y.is_active as yesterday_active,
      t.is_active AS today_active,
      y.last_active_season AS last_active_season,
      1996 AS current_season
    FROM
      yesterday y
      FULL OUTER JOIN today t ON y.player_name = t.player_name
  )
SELECT
  player_name,
  CASE
    WHEN today_active IS NULL THEN FALSE
    ELSE TRUE
  END AS is_active,
  CASE
    WHEN today_active IS NOT NULL THEN current_season
    ELSE last_active_season
  END AS last_active_season,
  CASE
    WHEN last_active_season IS NULL THEN 'New'
    WHEN (current_season - last_active_season) > 1
    AND today_active IS NULL THEN 'Stayed Retired'
    WHEN (current_season - last_active_season) > 1
    AND today_active IS NOT NULL THEN 'Returned from Retirement'
    WHEN (current_season - last_active_season) <= 1
    AND today_active IS NULL THEN 'Retired'
    WHEN (current_season - last_active_season) <= 1
    AND today_active IS NOT NULL THEN 'Continued Playing'
  END AS seasons_state,
  current_season
FROM
  aggregated