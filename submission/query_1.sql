INSERT into supreethkabbin.nba_players_state_tracker
-- CTE to track 'existing' player data from season 2000
WITH yesterday AS (
    SELECT 
        player_name,
        first_active_season,
        last_active_season,
        active_seasons,
        player_state,
        season
    FROM supreethkabbin.nba_players_state_tracker
    WHERE season = 2000
),

-- CTE to record incoming player data from the next season
today AS (
    SELECT 
        player_name,
        MAX(is_active) AS is_active,
        MAX(current_season) AS active_season
    FROM bootcamp.nba_players
    WHERE current_season = 2001
    GROUP BY player_name
),

-- CTE to combine data from both 'yesterday' and 'today'
combined AS (
    SELECT
        COALESCE(y.player_name, t.player_name) AS player_name, 
        COALESCE(y.first_active_season, t.active_season) AS first_active_season, 
        y.last_active_season AS last_active_season_previous,
        t.is_active,
        COALESCE(t.active_season, y.last_active_season) AS last_active_season,
        CASE
            -- No prior seasons, hence create new seasons array
            WHEN y.active_seasons IS NULL THEN ARRAY[t.active_season]
            -- Inactive in current season, hence use prior active seasons
            WHEN t.active_season IS NULL THEN y.active_seasons
            -- Active in current season, hence append incoming data
            WHEN t.active_season IS NOT NULL AND t.is_active THEN y.active_seasons || ARRAY[t.active_season]
            -- Use prior active seasons
            ELSE y.active_seasons
        END AS active_seasons,
        -- track current season
        COALESCE(y.season + 1, t.active_season) AS season
    FROM
        yesterday y
        FULL OUTER JOIN today t ON y.player_name = t.player_name
)

-- Categorize players based on activity into a state change-tracking field
SELECT 
    player_name,
    first_active_season,
    last_active_season,
    active_seasons,
    CASE
        WHEN is_active AND last_active_season_previous IS NULL THEN 'New'
        WHEN is_active AND season - last_active_season_previous = 1 THEN 'Continued Playing'
        WHEN is_active AND season - last_active_season_previous > 1 THEN 'Returned from Retirement'
        WHEN NOT is_active AND season - last_active_season_previous = 1 THEN 'Retired'
        ELSE 'Stayed Retired'
    END AS player_state,
    season
FROM combined