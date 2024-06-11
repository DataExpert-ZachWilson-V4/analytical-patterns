--CTE layers:
--last_year and this_year: basic components of cumulative queries
--combined: joining the 2 dataframes to incorporate latest info of players
--SELECT query: player name + active seasons + active state column

INSERT INTO
  derekleung.nba_player_state_change
WITH
  last_year AS (
    SELECT
      *
    FROM
      derekleung.nba_player_state_change
    WHERE
      current_season = 1997
  ),
--only choosing records where players are active in chosen year
  this_year AS (
    SELECT
      player_name,
      MAX(current_season) AS active_season
    FROM
      bootcamp.nba_players
    WHERE
      current_season = 1998 and is_active = True
    GROUP BY
      player_name
  ),
  combined AS (
    SELECT
      COALESCE(ly.player_name, ty.player_name) AS player_name,
      COALESCE(ly.first_active_season, ty.active_season) AS first_active_season,
      ly.last_active_season AS active_season_last_year,
      ty.active_season,
      COALESCE(ty.active_season, ly.last_active_season) AS last_active_season,
      CASE
        WHEN ly.seasons_active IS NULL THEN ARRAY[ty.active_season]
        WHEN ty.active_season IS NULL THEN ly.seasons_active
        ELSE ly.seasons_active || ARRAY[ty.active_season]
      END AS seasons_active,
      1998 AS current_season
    FROM
      last_year ly
      FULL OUTER JOIN this_year ty ON ly.player_name = ty.player_name
  )
SELECT
  player_name,
  first_active_season,
  last_active_season,
  seasons_active,
  -- active state is defined as follows:
  -- either new or not new
  -- if not new: last/this year in/out: 4 combinations
  -- 5 cases in total
  CASE
    WHEN active_season - first_active_season = 0 THEN 'New'
    WHEN active_season - last_active_season = 0 THEN 'Continued Playing'
    WHEN active_season - active_season_last_year > 1 THEN 'Returned from retirement'
    WHEN active_season IS NULL
    AND current_season - last_active_season = 1 THEN 'Retired'
    ELSE 'Stayed Retired'
  END AS active_state,
  current_season
FROM
  combined
