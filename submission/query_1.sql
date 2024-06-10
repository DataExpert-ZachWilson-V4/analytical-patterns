

-- Insert the final results into the nba_players_change_tracking table
INSERT INTO sumanacheera.nba_players_change_tracking
-- Define a CTE to get the data from the last season (1995)
with last_season as (
  select *
  from sumanacheera.nba_players_change_tracking
  where season = 1995
),
-- Define a CTE to get the current season (1996) player data
current_season as (
  select
    player_name,     -- Player's name
    is_active,       -- Player's active status 
    current_season   -- Current season (1996)
  from bootcamp.nba_players
  where current_season = 1996
),
-- Combine last season data with current season data using a full join
combined as (
  select 
    ls.last_active_season as previous_last_active_season,    -- Last active season from previous data
    cs.is_active,                                            -- Current active status
    coalesce(ls.player_name, cs.player_name) as player_name, -- Player's name from either dataset
    coalesce(
      ls.first_active_season, if(cs.is_active, cs.current_season, null)
    ) as first_active_season,                                -- First active season (new players get current season)
    coalesce(if(cs.is_active, cs.current_season, null), ls.last_active_season)
      as last_active_season,                                 -- Last active season (updated for active players)
    case
      when
        ls.seasons_active is null and cs.is_active
        then array[cs.current_season]                        -- New player entering the league
      when
        ls.seasons_active is not null
        and (not cs.is_active or cs.is_active is null)       -- Player retiring or remaining retired
        then ls.seasons_active
      when
        ls.seasons_active is not null and cs.is_active       -- Continued active player
        then ls.seasons_active || array[cs.current_season]
    end as seasons_active,                                   -- Array of active seasons
    coalesce(cs.current_season, ls.season + 1) as season     -- Current season or inferred next season
  from last_season as ls
  full join current_season as cs
    on ls.player_name = cs.player_name
)
-- Select the necessary columns and determine the player's yearly active state
  select
    player_name,            -- Player's name
    first_active_season,    -- Player's first active season
    last_active_season,     -- Player's last active season
    seasons_active,         -- Array of seasons the player was active
    case
      when season - first_active_season = 0 then 'New'                        -- Player entering the league
      when season - previous_last_active_season = 1 then 'Continued Playing'  -- Player continuing from last season
      when
        is_active and season - previous_last_active_season > 1                -- Player returning from retirement
        then 'Returned from Retirement'
      when
        not is_active and season - previous_last_active_season = 1            -- Player retiring
        then 'Retired'
      else 'Stayed Retired'                                                   -- Player remaining retired
    end as yearly_active_state,                                               -- Player's state change
    season                                                                    -- Current season
  from combined
