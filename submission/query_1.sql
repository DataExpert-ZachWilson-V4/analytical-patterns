-- CREATE OR REPLACE TABLE bgar.nba_players_tracker ( 
--     player_name VARCHAR,
--     first_active_season INT,
--     last_active_season INT,
--     seasons_active ARRAY(INT),
--     season_active_state VARCHAR,
--     season INT
-- ) WITH 
--     (format = 'PARQUET', 
--     partitioning = ARRAY['season'])

INSERT INTO bgar.nba_players_tracker
WITH
    yesterday as (
        SELECT
            *
        FROM bgar.nba_players_tracker
        WHERE season = 1995
    ),
    today as (
        SELECT
            player_name,
            current_season
        FROM bootcamp.nba_players
        WHERE current_season = 1996
        AND is_active = true
    ),
    combined as (
        SELECT
            COALESCE(y.player_name, t.player_name) as player_name,
            COALESCE(y.first_active_season, t.current_season) as first_active_season,
            COALESCE(t.current_season, y.last_active_season) as last_active_season,
            CASE
                WHEN y.seasons_active IS NULL THEN ARRAY[t.current_season]
                WHEN t.current_season IS NULL THEN y.seasons_active
                ELSE y.seasons_active || ARRAY[t.current_season]
            END AS seasons_active,
            y.last_active_season as active_previous_season,
            t.current_season as active_season,
            1996 as season
        FROM yesterday y 
        FULL OUTER JOIN today t
        ON y.player_name = t.player_name
    )
SELECT
    player_name,
    first_active_season,
    last_active_season,
    seasons_active,
    CASE
        WHEN active_season - first_active_season = 0 THEN 'New'
        WHEN active_season - active_previous_season > 1 THEN 'Returned from Retirement'
        WHEN active_season - last_active_season = 0 THEN 'Continued Playing'
        WHEN active_season IS NULL AND season - last_active_season = 1 THEN 'Retired' 
        ELSE 'Stayed Retired'
    END AS season_active_state,
    season
FROM combined
