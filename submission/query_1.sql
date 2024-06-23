-- Query that categorizes players state changes from our slowly changing dimension table created in previous session
WITH player_status AS (
    SELECT
        player_name,
        is_active,
        start_season,
        end_season,
        current_season,
        LAG(is_active) OVER (PARTITION BY player_name ORDER BY start_season) AS prev_is_active, --uses lag to get the previous is active record
        LAG(end_season) OVER (PARTITION BY player_name ORDER BY start_season) AS prev_end_season --uses lag to get the previous start season
    FROM
        bootcamp.nba_players_scd
),
state_changes AS (
    SELECT
        player_name,
        start_season,
        end_season,
        current_season,
        is_active,
        prev_is_active,
        prev_end_season,
        CASE
            WHEN prev_is_active IS NULL AND is_active = true THEN 'New'
            WHEN prev_is_active = true AND is_active = false THEN 'Retired'
            WHEN prev_is_active = false AND is_active = true THEN 'Returned from Retirement'
            WHEN prev_is_active = true AND is_active = true THEN 'Continued Playing'
            WHEN prev_is_active = false AND is_active = false THEN 'Stayed Retired'
            ELSE 'Unknown'
        END AS state_change --based on the results of the lag categorize the state change of the user at each slowly changing dimension
    FROM
        player_status
)
SELECT
    player_name,
    start_season,
    end_season,
    current_season,
    state_change
FROM
    state_changes
ORDER BY
    player_name, start_season
