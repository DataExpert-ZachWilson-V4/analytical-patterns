-- State Change-Tracking table for `nba_players`.
CREATE TABLE nba_players_state_tracking AS
SELECT
  player_name,
  seasons,
  is_active,
  years_since_last_active,
  current_season,
  CASE
    -- Currently active but no previous seasons are 'New' players
    WHEN is_active AND CARDINALITY(seasons) = 1 THEN 'New'
    -- Not active and were active in the previous season are 'Retired' players
    WHEN NOT is_active AND years_since_last_active = 1 THEN 'Retired'
    -- Active, have played in the previous season, and have played in multiple seasons are 'Continued Playing' players
    WHEN is_active AND CARDINALITY(seasons) > 1 AND years_since_last_active = 0 THEN 'Continued Playing'
    -- Active and last played in a season more than one year ago are 'Returned from Retirement' players
    WHEN is_active AND years_since_last_active > 1 THEN 'Returned from Retirement'
    -- Not active and last played in a season more than one year ago are 'Stayed Retired' players
    WHEN NOT is_active AND years_since_last_active > 1 THEN 'Stayed Retired'
  END AS player_state
FROM bootcamp.nba_players