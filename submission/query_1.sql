-- Create a common table expression (CTE) called last_year
-- to retrieve all player data from the previous season (1999)
WITH
    last_year AS (
        SELECT
            *
        FROM
            videet.nba_players_state_tracking
        WHERE
            season = 1995
    ),
    -- Create another CTE called this_year
    -- to retrieve player names, active season, and active status for the current season (1996)
    this_year AS (
        SELECT
            player_name,
            MAX(current_season) AS active_season,
            MAX(is_active) AS is_active
        FROM
            bootcamp.nba_players
        WHERE
            current_season = 1996
        GROUP BY
            player_name
    ),
    -- Create a third CTE called combined
    -- to combine data from last_year and this_year CTEs
    -- and calculate additional columns for first active season, last active season,
    -- seasons active, and the current season
    combined AS (
        SELECT
            COALESCE(ly.player_name, ty.player_name) AS player_name,
            COALESCE(ly.first_active_season, CASE WHEN ty.is_active THEN ty.active_season END) AS first_active_season,
            ly.last_active_season AS last_active_year,
            ty.is_active,
            CASE
                WHEN ly.seasons_active IS NULL THEN ARRAY[ty.active_season]
                WHEN ty.active_season IS NULL THEN ly.seasons_active
                ELSE ly.seasons_active || ARRAY[ty.active_season]
            END AS seasons_active,
            COALESCE(ly.season + 1, ty.active_season) AS season
        FROM
            last_year ly
            FULL OUTER JOIN this_year ty ON ty.player_name = ly.player_name
    )

-- Select the required columns from the combined CTE
-- and calculate the yearly_active_state based on the given conditions
INSERT INTO videet.nba_players_state_tracking
SELECT
    player_name,
    first_active_season,
    last_active_year,
    seasons_active,
    CASE
        WHEN first_active_season - last_active_year = 0 AND is_active THEN 'New'
        WHEN season - last_active_year = 1 AND NOT is_active THEN 'Retired'
        WHEN season - last_active_year = 1 AND is_active THEN 'Continued Playing'
        WHEN season - last_active_year > 1 AND is_active THEN 'Returned from Retirement'
        ELSE 'Stayed Retired'
    END AS yearly_active_state,
    season
FROM
    combined