-- Query to track state changes for nba_players
-- Select players season = 1995
WITH
   last_year AS (
        SELECT
            *
        FROM
            akshayjainytl54781.nba_players_track -- see notes.txt for table's schema
        WHERE
            season = 1995
    ),
    current_year AS (
        SELECT
            player_name,
            current_season
        FROM
            bootcamp.nba_players
        WHERE
            current_season = 1996
            and is_active = true -- Only choosing active players
    ),
    combined as (
        SELECT
            COALESCE(y.player_name, t.player_name) as player_name,
            COALESCE(y.first_active_season, t.current_season) as first_active_season,
            COALESCE(t.current_season, y.last_active_season) as last_active_season,
            CASE
                WHEN y.seasons_active IS NULL THEN ARRAY[t.current_season] -- No last active season
                WHEN t.current_season IS NULL THEN y.seasons_active -- No current active season
                ELSE y.seasons_active || ARRAY[t.current_season] -- Merge both last and current active seasons
            END as seasons_active,
            y.last_active_season as active_previous_season,
            t.current_season as active_season,
            1996 as season
        FROM
            last_year y
        FULL OUTER JOIN current_year t 
        ON y.player_name = t.player_name
    )
SELECT
    player_name,
    first_active_season,
    last_active_season,
    seasons_active,
    CASE
        WHEN active_season IS NOT NULL AND active_previous_season IS NULL THEN 'New' -- New to the league
        WHEN active_season IS NOT NULL AND active_previous_season IS NOT NULL THEN 'Continued Playing' -- Continued playing
        WHEN active_season IS NOT NULL AND active_previous_season IS NULL AND last_active_season < active_season - 1 THEN 'Returned from Retirement' -- check if a player was previously active, retired, and then became active again
        WHEN active_season IS NULL AND active_previous_season IS NOT NULL THEN 'Retired' -- Retired
        ELSE 'Stayed Retired'
    END as season_active_state,
    season
FROM
    combined