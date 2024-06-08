CREATE OR REPLACE TABLE videet.nba_players_state_tracking AS
-- Create a CTE called last_year to select all records from the previous season (1999)
WITH
    last_year AS (
        SELECT
            *
        FROM
            videet.nba_players_state_tracking
        WHERE
            season = 1996
    ),
    -- Create another CTE called this_year
    -- to select the maximum active season and active status for each player
    -- for the current season (2000)
    this_year AS (
        SELECT
            player_name,
            MAX(current_season) AS active_season,
            MAX(is_active) AS is_active
        FROM
            bootcamp.nba_players
        WHERE
            current_season = 1997
        GROUP BY
            player_name
    ),
    -- Create a third CTE called combined
    -- to combine data from last_year and this_year CTEs
    -- and calculate additional columns for first active season,
    -- last active season, seasons active, and the current season
    combined AS (
        SELECT
            COALESCE(ly.player_name, ty.player_name) AS player_name,
            COALESCE(
                ly.first_active_season,
                (
                    CASE
                        WHEN ty.is_active THEN ty.active_season
                    END
                )
            ) AS first_active_season, -- Determine first active season
            ly.last_active_season AS last_active_year, -- Last active season from last year's data
            ty.is_active, -- Current active status
            COALESCE(
                (
                    CASE
                        WHEN ty.is_active THEN ty.active_season
                    END
                ),
                ly.last_active_season
            ) AS last_active_season, -- Determine last active season
            CASE
                WHEN ly.seasons_active IS NULL THEN ARRAY[ty.active_season]
                WHEN ty.active_season IS NULL THEN ly.seasons_active
                ELSE ly.seasons_active || ARRAY[ty.active_season]
            END AS seasons_active,
            COALESCE(ly.season + 1, ty.active_season) AS season
        FROM
            last_year ly
            FULL OUTER JOIN this_year ty ON ly.player_name = ty.player_name
    )

-- Select the required columns from the combined CTE
-- and calculate the yearly_active_state based on the given conditions
SELECT
    player_name,
    first_active_season,
    last_active_season,
    seasons_active,
    CASE
        WHEN first_active_season - last_active_season = 0
        AND is_active THEN 'New' -- Player entering the league
        WHEN season - last_active_year = 1
        AND NOT is_active THEN 'Retired' -- Player leaving the league
        WHEN season - last_active_year = 1
        AND is_active THEN 'Continued Playing' -- Player staying in the league
        WHEN season - last_active_year > 1
        AND is_active THEN 'Returned from Retirement' -- Player coming out of retirement
        ELSE 'Stayed Retired' -- Player staying out of the league
    END AS yearly_active_state,
    season
FROM
    combined