WITH lagged AS (
    -- WIth lagged query, we are bringing the column 
    -- that represent if player was active in previous year
    SELECT player_name,
        LAG(is_active, 1) OVER (
            PARTITION BY player_name
            ORDER BY current_season
        ) AS is_last_year_active,
        is_active,
        current_season
    FROM bootcamp.nba_players
),
-- With stated column, we are calculating the state based on current and last year activity
stated AS (
    SELECT player_name,
        current_season,
        is_last_year_active,
        is_active,
        CASE
            WHEN is_active
            AND is_last_year_active IS NULL THEN 'New'
            WHEN NOT is_active
            AND is_last_year_active THEN 'Retired'
            WHEN (
                is_last_year_active IS NOT NULL
                AND is_last_year_active
            )
            AND is_active THEN 'Continued Playing'
            WHEN (NOT is_last_year_active)
            AND is_active THEN 'Returned from Retirement'
            WHEN (NOT is_last_year_active)
            AND (NOT is_active) THEN 'Stayed Retired'
        END AS state
    FROM lagged
)
SELECT *
FROM stated