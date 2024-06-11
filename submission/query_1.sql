INSERT INTO nba_players_state_change
WITH yesterday AS (
    SELECT
        *
    FROM
        nba_players_state_change
    WHERE
        season = 1995
),
--deduplicate nba_players
ranked_today AS (
    SELECT
        *,
        --dedupe on player_name
        ROW_NUMBER()
            OVER (PARTITION BY player_name, current_season)
        AS row_num 
        FROM bootcamp.nba_players
        WHERE current_season = 1996
),
today AS (
    SELECT
        player_name,
        is_active,
        years_since_last_active,
        current_season
    FROM
        ranked_today
    WHERE
        row_num = 1
),
combined as (
    SELECT
        -- if player is appearing for the first time, get the player name
        COALESCE(y.player_name, t.player_name) as player_name,
        -- if player is appearing for the first time, get current_season as their first active season
        COALESCE(y.first_active_season, t.current_season) as first_active_season,
        CASE
            -- if player is appearing for the first time, their current season is also their last active season
            WHEN y.last_active_season IS NULL THEN t.current_season
            -- if they are active this season, then their current season is last active season
            WHEN t.is_active = true THEN t.current_season
            -- otherwise their previous last active season is their last active season
            ELSE y.last_active_season
        END as last_active_season,
        -- need this for active state calculation
        t.is_active as active_status_today,
        -- need this for active state calculation
        t.years_since_last_active as years_since_last_active,
        -- need this for active state calculation
        y.last_active_season as last_active_season_yesterday,
        CASE 
            -- if appearing for the first time, create seasons_active array with current season
            WHEN y.seasons_active IS NULL THEN ARRAY[t.current_season]
            -- if player not active this season, then seasons_active is unchanged from yesterday
            WHEN t.is_active = false THEN y.seasons_active
            -- otherwise player is active this season, append new season to seasons_active
            ELSE y.seasons_active || ARRAY[t.current_season]
        END AS seasons_active,
        1996 AS season
    FROM
        yesterday y
    FULL OUTER JOIN today t
        ON y.player_name = t.player_name
)
SELECT 
    player_name,
    first_active_season,
    last_active_season,
    seasons_active,
    CASE
        -- if players first active season is current season, then they are new
        WHEN season - first_active_season = 0 THEN 'New'
        -- if player hasnt been active in one year, then they just retired
        WHEN years_since_last_active = 1 THEN 'Retired'
        -- if player is active, AND their new last_active_season yesterday was last year, then they continued playing
        WHEN active_status_today = true AND last_active_season - last_active_season_yesterday = 1 THEN 'Continued Playing'
        -- if they are active this season, but their last active season yesterday was greater than last year, then returned from retirement
        WHEN active_status_today = true AND last_active_season - last_active_season_yesterday > 1 THEN 'Returned from Retirement'
        -- if their years since last active is greater than, then they stayed retired
        WHEN years_since_last_active > 1 THEN 'Stayed Retired'
    END as season_active_state,
    season
FROM combined