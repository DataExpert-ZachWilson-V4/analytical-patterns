--Obtain data from previous_year

WITH previous_year AS (
    SELECT *
    FROM grisreyesrios.nba_players_state_tracking
    WHERE year = 1995
),
current_year AS (
    SELECT player_name,
        MAX(current_season) AS active_year
    FROM bootcamp.nba_players
    WHERE is_active = true
        AND current_season = 1996
    GROUP BY player_name
),
combined AS (
    SELECT COALESCE(y.player_name, t.player_name) AS player_name,
        COALESCE(y.first_active_year, t.active_year) AS first_active_year,
        y.last_active_year AS last_active_year_previous_year,
        t.active_year,
        COALESCE(t.active_year, y.last_active_year) AS last_active_year,
        CASE
            WHEN y.years_active IS NULL THEN ARRAY [t.active_year]
            WHEN t.active_year IS NULL THEN y.years_active
            ELSE y.years_active || ARRAY [t.active_year]
        END AS years_active,
        1996 AS partition_year
    FROM previous_year y
        FULL OUTER JOIN current_year t ON y.player_name = t.player_name
)
SELECT player_name,
    first_active_year,
    last_active_year,
    years_active,
    CASE
        WHEN (active_year - first_active_year) = 0 THEN 'New' -- new player, this year is player's first year ever
        WHEN (active_year - last_active_year_previous_year) = 1 THEN 'Continued Playing' -- player stays in league, last active year from previous year is 1 less than current year
        WHEN (active_year - last_active_year_previous_year) > 1 THEN 'Returned from Retirement' -- player has returned, last active year from previous year is at least 1 more than current year (Michael Jordan returning in 2001 after retiring in 1997)
        WHEN active_year IS NULL -- no player data for current year
        AND (partition_year - last_active_year) = 1 THEN 'Retired' -- and current year is 1 year after last active year
        ELSE 'Stayed Retired'
    END AS active_state,
    partition_year
FROM combined