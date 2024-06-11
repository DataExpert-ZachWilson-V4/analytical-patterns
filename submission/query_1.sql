WITH
    nba_players_base AS (
        SELECT
            player_name,
            is_active,
            current_season,
            LAG(is_active) OVER (
                PARTITION BY
                    player_name
                ORDER BY
                    current_season
            ) AS lag_is_active
        FROM
            bootcamp.nba_players
    )
SELECT
    player_name,
    current_season,
    lag_is_active,
    is_active,
    CASE
        WHEN lag_is_active IS NULL THEN 'New'
        WHEN lag_is_active AND NOT is_active THEN 'Retired'
        WHEN lag_is_active AND is_active THEN 'Continued Playing'
        WHEN NOT lag_is_active AND is_active THEN 'Returned from Retirement'
        WHEN NOT lag_is_active AND NOT is_active THEN 'Stayed Retired'
    END AS state
FROM
    nba_players_base