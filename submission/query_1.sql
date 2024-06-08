-- Table creation/schema
-- CREATE OR REPLACE TABLE barrocaeric.nba_players_track(
--     player_name VARCHAR,
--     first_active_season INT,
--     last_active_season INT,
--     seasons_active ARRAY(INT),
--     season_active_state VARCHAR,
--     partition_season INT
-- )
-- WITH
--     (format = 'PARQUET', partitioning = ARRAY['partition_season'])

INSERT INTO barrocaeric.nba_players_track
WITH
    yesterday AS (
        SELECT
            *
        FROM
            barrocaeric.nba_players_track
        WHERE
            partition_season = 1995
    ),
    today AS (
        SELECT
            player_name,
            current_season
        FROM
            bootcamp.nba_players
        WHERE
            -- eliminate the row where the player is not active
            current_season = 1996
            and is_active = true
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
            END as seasons_active,
            y.last_active_season as active_previous_season,
            t.current_season as active_season,
            1996 as partition_season
        FROM
            yesterday y
            FULL OUTER JOIN today t ON y.player_name = t.player_name
    )
SELECT
    player_name,
    first_active_season,
    last_active_season,
    seasons_active,
    CASE
        WHEN active_season - first_active_season = 0 THEN 'New'
        -- The order of the following 2 rows matter, if they were swapped the results would be wrong
        WHEN active_season - active_previous_season > 1 THEN 'Returned from Retirement'
        WHEN active_season - last_active_season = 0 THEN 'Continued Playing'
        WHEN active_season IS NULL
        AND partition_season - last_active_season = 1 THEN 'Retired'
        ELSE 'Stayed Retired'
    END as season_active_state,
    partition_season
FROM
    combined
