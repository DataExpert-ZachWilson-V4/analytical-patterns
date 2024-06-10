-- This query inserts data into "nba_players_state_tracking" incrementally one year at time while maintaining/updating state for each season.
-- The goal is to determine the state of each NBA player for the current season (1996) based on their activity status in the previous season (1995) and the current season.
-- A player's playing STATE is captured and is updated every new season as below.
-- 1. 'New' - A player who's data is in current season but not on previous seasons.
-- 2. 'Retired' - A player who was active in the previous season but is not active in the current season.
-- 3. 'Returned from Retirement' - A player who was not active in the previous season but has become active in the current season.
-- 4. 'Continued Playing' - A player who was active in both the previous season and the current season.
-- 5. 'Stayed Retired' - A player who was not active in the previous season and remains inactive in the current season.

--INSERT INTO shashankkongara.nba_players_state_tracking
WITH
  -- Subquery to select records from the previous season (1995)
  yesterday AS (
    SELECT
      *
    FROM
      shashankkongara.nba_players_state_tracking
    WHERE
      current_season = 1995
  ),
  -- Subquery to select player names and their latest active season from the previous season (1995)
  yesterday_players AS (
    SELECT
      player_name,
      MAX(
        CASE
          WHEN is_active = TRUE THEN current_season
          ELSE NULL
        END
      ) AS active_season_yesterday
    FROM
      bootcamp.nba_players
    WHERE
      current_season = 1995
    GROUP BY
      player_name
  ),
  -- Subquery to select player names and their latest active season for the current season (1996)
  today AS (
    SELECT
      player_name,
      MAX(
        CASE
          WHEN is_active = TRUE THEN current_season
          ELSE NULL
        END
      ) AS active_season
    FROM
      bootcamp.nba_players
    WHERE
      current_season = 1996
    GROUP BY
      player_name
  ),
  -- Joining yesterday's players with today's players to track changes
  joined AS (
    SELECT 
      COALESCE(a.player_name, b.player_name) AS player_name,
      COALESCE(a.active_season_yesterday, NULL) AS active_season_yesterday,
      b.active_season AS active_season
    FROM 
      yesterday_players a 
    FULL OUTER JOIN 
      today b 
    ON 
      a.player_name = b.player_name
  ),
  -- Combining data to determine active seasons and player state changes
  combined AS (
    SELECT
      COALESCE(y.player_name, t.player_name) AS player_name,
      COALESCE(y.first_season_active, t.active_season) AS first_season_active,
      COALESCE(t.active_season, y.last_season_active) AS last_season_active,
      y.last_season_active AS last_season_active_yesterday,
      t.active_season AS active_season_today,
      t.active_season_yesterday AS active_season_yesterday,
      CASE
        WHEN y.seasons_active IS NULL THEN ARRAY[t.active_season]
        WHEN t.active_season IS NULL THEN y.seasons_active
        ELSE y.seasons_active || ARRAY[t.active_season]
      END AS seasons_active,
      1996 AS partition_season
    FROM
      yesterday y
    FULL OUTER JOIN 
      joined t 
    ON 
      y.player_name = t.player_name
  )
-- Final selection of player state changes
SELECT
  player_name,
  first_season_active,
  last_season_active,
  seasons_active,
  CASE
    WHEN active_season_today = first_season_active THEN 'New'
    WHEN active_season_today IS NULL AND (partition_season - last_season_active) = 1 THEN 'Retired'
    WHEN active_season_today IS NOT NULL AND active_season_yesterday IS NULL THEN 'Returned from Retirement'
    WHEN active_season_today IS NOT NULL AND active_season_yesterday IS NOT NULL THEN 'Continued Playing'
    ELSE 'Stayed Retired'
  END AS current_season_active_state,
  partition_season
FROM
  combined

