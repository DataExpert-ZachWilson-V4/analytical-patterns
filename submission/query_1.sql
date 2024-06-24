-- Query that categorizes players state changes from our slowly changing dimension table created in previous session
INSERT INTO amaliah21315.nba_player_state_track2 
WITH unnested_seasons AS (
    SELECT
        player_name,
        arr.season AS season_year,
        is_active,
        current_season,
        ROW_NUMBER() OVER (PARTITION BY player_name ORDER BY player_name, arr.season, current_season) AS rn -- categorizing the records and ordering by seasons 
    FROM
        amaliah21315.nba_players
        CROSS JOIN UNNEST(seasons) AS arr --unnest array seasons to get each line item based on season year
),
player_status AS (
    SELECT
        player_name,
        MIN(season_year) OVER (PARTITION BY player_name) AS start_season, 
        MAX(season_year) OVER (PARTITION BY player_name) AS end_season,
        current_season,
        is_active,
        LAG(is_active) OVER (PARTITION BY player_name ORDER BY season_year) AS prev_is_active, --lag to get the previous period is active
        LAG(season_year) OVER (PARTITION BY player_name ORDER BY season_year) AS prev_season  -- lag to get the previous season
    FROM
        unnested_seasons
),
state_changes AS (
    SELECT
        player_name,
        start_season,
        end_season,
        current_season,
        is_active,
        prev_is_active,
        prev_season,
        CASE
            WHEN prev_is_active IS NULL AND is_active = true THEN 'New'
            WHEN prev_is_active = true AND is_active = false THEN 'Retired'
            WHEN prev_is_active = false AND is_active = true THEN 'Returned from Retirement'
            WHEN prev_is_active = true AND is_active = true THEN 'Continued Playing'
            WHEN prev_is_active = false AND is_active = false THEN 'Stayed Retired'
            WHEN prev_is_active IS NULL AND is_active IS NULL THEN 'Never Played'
            ELSE 'Unknown'
        END AS state_change --to define the state change
    FROM
        player_status
)
SELECT
    player_name,
    start_season,
    end_season,
    current_season,
  is_active,
        prev_is_active,
        state_change
FROM
    state_changes
ORDER BY
    player_name, start_season