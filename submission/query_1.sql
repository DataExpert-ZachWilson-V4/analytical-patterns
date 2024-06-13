-- query 1 State change tracking for nba players

WITH
    yesterday as (
        SELECT
            *
        FROM aayushi.nba_players_tracker
        WHERE season = 2001
    ),  -- Cte to get nba_players history upto the given year
    today as (
        SELECT
            player_name,
            current_season
        FROM bootcamp.nba_players
        WHERE current_season = 2002
        AND is_active = true
    ), -- cte to get current to get data for next year
    combined as (
        SELECT
            COALESCE(y.player_name, t.player_name) as player_name,
            COALESCE(y.first_active_season, t.current_season) as first_active_season,
            COALESCE(t.current_season, y.last_active_season) as last_active_season,
            -- tracking change based on seasons_active and current_season 
            CASE
                WHEN y.seasons_active IS NULL THEN ARRAY[t.current_season]
                WHEN t.current_season IS NULL THEN y.seasons_active
                ELSE y.seasons_active || ARRAY[t.current_season]
            END AS seasons_active,
            y.last_active_season as active_previous_season,
            t.current_season as active_season,
            COALESCE(y.season+1, t.current_season) as season
        FROM yesterday y 
        FULL OUTER JOIN today t
        ON y.player_name = t.player_name
    ) -- Cte to combine data

-- Final Selection based on activity data
SELECT
    player_name,
    first_active_season,
    last_active_season,
    seasons_active,
    CASE
        WHEN active_season - first_active_season = 0 THEN 'New'                             -- New players entering the league
        WHEN active_season IS NULL AND season - last_active_season = 1 THEN 'Retired'       -- Players who retired after last season  
        WHEN active_season - last_active_season = 0 THEN 'Continued Playing'                -- Players who continued from last season
        WHEN active_season - active_previous_season > 1 THEN 'Returned from Retirement'     -- Players returning after a gap     
        ELSE 'Stayed Retired'     -- Players who stays out of the league
    END AS season_active_state,
    season
FROM combined