INSERT INTO pratzo.players_state_tracking
-- Get previous season data - first iteration is empty
WITH last_season AS (
    SELECT * 
    FROM pratzo.players_state_tracking 
    WHERE season = 2003 
),
-- Get current season data
current_season AS (
    SELECT player_name,
           is_active,
           current_season
    FROM bootcamp.nba_players
    WHERE current_season = 2004
),
-- Get active and last season information
combined AS (
    SELECT
        COALESCE(ls.player_name, cs.player_name) AS player_name,
        COALESCE(ls.first_active_season, IF(cs.is_active, cs.current_season, NULL)) AS first_active_season, -- Get if this season was the first active
        COALESCE(IF(cs.is_active, cs.current_season, NULL), ls.last_active_season) AS last_active_season, -- Get if this season was the last active 
        CASE
            WHEN ls.seasons_active IS NULL AND cs.is_active THEN ARRAY[cs.current_season]
            WHEN ls.seasons_active IS NOT NULL AND (cs.is_active IS NULL OR NOT cs.is_active) THEN ls.seasons_active
            ELSE ls.seasons_active || ARRAY[cs.current_season] 
        END AS seasons_active, -- Array containing all the active seasons
        cs.is_active,
        COALESCE(ls.season + 1, cs.current_season) AS season
    FROM last_season AS ls
    FULL OUTER JOIN current_season AS cs
    ON ls.player_name = cs.player_name
)
SELECT
  player_name,
  first_active_season,
  last_active_season,
  seasons_active,
  CASE
      WHEN season - first_active_season  = 0 AND is_active THEN 'New' -- Current season matches the first active one for the player
      WHEN season - last_active_season = 1 AND is_active THEN 'Continued Playing' -- Last active season was one year before the current, but the player is still active
      WHEN season - last_active_season = 1 AND NOT is_active THEN 'Retired' -- Last active season was one year before the current, but the player is no more active
      WHEN season - last_active_season > 1 AND is_active THEN 'Returned from Retirement' -- Last active season was more than one year before the current, but the player is still active
      ELSE 'Stayed Retired' -- Last active season was more than one year before the current and the player is no more active
  END AS player_state,
  season
FROM combined