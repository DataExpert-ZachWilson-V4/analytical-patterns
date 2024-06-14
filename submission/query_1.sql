/*

- Write a query (`query_1`) that does state change tracking for `nba_players`. Create a state change-tracking field that takes on the following values:
  - A player entering the league should be `New`
  - A player leaving the league should be `Retired`
  - A player staying in the league should be `Continued Playing`
  - A player that comes out of retirement should be `Returned from Retirement`
  - A player that stays out of the league should be `Stayed Retired`
  
*/

--Table creation/schema
/* CREATE OR REPLACE TABLE harathi.nba_players_state_track(
    player_name VARCHAR,
    first_active_season INT,
    last_active_season INT,
    seasons_active ARRAY(INT),
    season_active_state VARCHAR,
    season INT
)
WITH
    (format = 'PARQUET', partitioning = ARRAY['season']) */

INSERT INTO harathi.nba_players_state_track
WITH
    yesterday AS (
        SELECT
            *
        FROM
            harathi.nba_players_state_track
        WHERE
            season = 1995 --parametrize
    ),
    today AS (
        SELECT
            player_name,
            current_season
        FROM
            bootcamp.nba_players
        WHERE
            current_season = 1996 --parametrize
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
            1996 as season -- parametrize
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
        WHEN active_season - active_previous_season > 1 THEN 'Returned from Retirement'
        WHEN active_season - last_active_season = 0 THEN 'Continued Playing'
        WHEN active_season IS NULL AND season - last_active_season = 1 THEN 'Retired'
        ELSE 'Stayed Retired'
    END as season_active_state,
    season
FROM
    combined