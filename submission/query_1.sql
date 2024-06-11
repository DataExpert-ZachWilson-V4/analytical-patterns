    WITH
  expanded_seasons AS (
    SELECT distinct
      player_name,
      college,
      country,
      draft_year,
      years_since_last_active,
      is_active,
      season,
        CASE
        WHEN season = 1 THEN 'New'
        WHEN CAST(is_active AS INTEGER) = 0 AND years_since_last_active > 1 THEN 'Stayed Retired'
        WHEN CAST(is_active AS INTEGER) = 0 AND years_since_last_active > 0 THEN 'Retired'
        WHEN CAST(is_active AS INTEGER) = 1 AND years_since_last_active > 0 THEN 'Returned from Retirement'
        WHEN CAST(is_active AS INTEGER) = 1 THEN 'Continued Playing'
        ELSE 'Unknown'
    END AS player_state_change
    FROM
      bootcamp.nba_players,
      UNNEST (seasons) as season
  )
SELECT
  player_name,
  college,
  country,
  draft_year,
  COUNT(distinct season) AS season_count,
  player_state_change
FROM
  expanded_seasons
GROUP BY
  player_name,
  college,
  country,
  draft_year,
  player_state_change