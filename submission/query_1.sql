WITH incremental_seasons AS (
  SELECT
    player_name
    , CASE WHEN is_active THEN 1 ELSE 0 END as is_active
    , CASE WHEN LAG( is_active, 1 ) OVER ( PARTITION BY player_name ORDER BY current_season ) THEN 1 ELSE 0 END as is_active_last_season
    , current_season
  FROM saismail.nba_players
),
streaks AS (
  SELECT
    *
    , SUM( CASE WHEN is_active <> is_active_last_season THEN 1 ELSE 0 END ) OVER ( PARTITION BY player_name ORDER BY current_season ) as streak_identifier
  FROM incremental_seasons 
),
state_changes AS (
  SELECT
    *
    , CASE WHEN streak_identifier = 1 AND is_active <> is_active_last_season THEN 'New'
      WHEN is_active = is_active_last_season AND is_active = 1 THEN 'Continued Playing'
      WHEN is_active <> is_active_last_season AND is_active = 0 THEN 'Retired'
      WHEN is_active = is_active_last_season AND is_active = 0 THEN 'Stayed Retired'
      WHEN is_active <> is_active_last_season AND is_active = 1 THEN 'Returned from Retirement' END as player_status
  FROM streaks
)

SELECT
  player_name
  , MIN( current_season ) as start_season
  , MAX( current_season ) as end_season
  , player_status
FROM state_changes
GROUP BY
  player_name, player_status
ORDER BY 1,3