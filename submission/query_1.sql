INSERT INTO tejalscr.nba_players_state_change_tracking
WITH
  last_season AS (
    SELECT
      *
    FROM
      tejalscr.nba_players_state_change_tracking
    WHERE
      current_season = 2001
  ),
  current_season AS (
    SELECT
      distinct 
      player_name,
      is_active,
      current_season
    FROM
      bootcamp.nba_players
    WHERE
      current_season = 2002
  ),
  combined AS (
    SELECT
      COALESCE(l.player_name, c.player_name) AS player_name,
      COALESCE(
        l.first_active_season,
        CASE
          WHEN is_active = TRUE THEN c.current_season
          ELSE NULL
        END
      ) AS first_active_season,
      COALESCE(
        CASE
          WHEN is_active = TRUE THEN c.current_season
          ELSE NULL
        END,
        l.last_active_season
      ) AS last_active_season,
      CASE
        WHEN l.seasons_active IS NULL THEN ARRAY[
          CASE
            WHEN is_active = TRUE THEN c.current_season
            ELSE NULL
          END
        ]
        WHEN CASE
          WHEN is_active = TRUE THEN c.current_season
          ELSE NULL
        END IS NULL THEN l.seasons_active
        ELSE l.seasons_active || ARRAY[
          CASE
            WHEN is_active = TRUE THEN c.current_season
            ELSE NULL
          END
        ]
      END AS seasons_active,
      c.current_season,
      c.is_active
    FROM
      last_season l
      FULL OUTER JOIN current_season c ON l.player_name = c.player_name
  )
SELECT
  player_name,
  first_active_season,
  last_active_season,
  seasons_active,
  CASE
    WHEN is_active = true  AND last_active_season - first_active_season = 0 THEN 'New'
    WHEN is_active = true  AND last_active_season - first_active_season >= 1 THEN 'Continued playing'
    WHEN is_active = true  AND current_season - last_active_season > 1 THEN  'Returned from retirement'
    WHEN is_active <> true AND current_season - last_active_season  = 1 THEN 'Retired'
    WHEN is_active <> true AND current_season - last_active_season  > 1 THEN 'Stayed Retired'
  END AS active_state_change,
  current_season
FROM
  combined
