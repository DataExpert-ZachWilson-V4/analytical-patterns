INSERT into sasiram410.nba_players_track_status 
-- Define the 'yesterday' CTE to capture player data from the 2000 season
WITH yesterday AS (
    SELECT 
        player_name,
        first_active_season,
        last_active_season,
        active_seasons,
        player_state,
        season
    FROM sasiram410.nba_players_track_status
    WHERE season = 2000
),

-- Define the 'today' CTE to capture player activity status from the 2001 season
today AS (
    SELECT 
        player_name,
        MAX(is_active) AS is_active, -- Determine if the player is active in the current season
        MAX(current_season) AS active_season -- Determine the current season
    FROM bootcamp.nba_players
    WHERE current_season = 2001
    GROUP BY player_name
),

-- Combine data from both 'yesterday' and 'today' CTEs
combined AS (
    SELECT
        COALESCE(y.player_name, t.player_name) AS player_name, -- Use player name from either 'yesterday' or 'today'
        COALESCE(y.first_active_season, t.active_season) AS first_active_season, -- Use first active season from 'yesterday' or determine from 'today'
        y.last_active_season AS last_active_season_previous, -- Last active season from 'yesterday'
        t.is_active, -- Current active status
        COALESCE(t.active_season, y.last_active_season) AS last_active_season, -- Determine last active season
        CASE
            WHEN y.active_seasons IS NULL THEN ARRAY[t.active_season] -- If no previous active seasons, start new array
            WHEN t.active_season IS NULL THEN y.active_seasons -- If no current active season, use previous active seasons
            WHEN t.active_season IS NOT NULL AND t.is_active THEN y.active_seasons || ARRAY[t.active_season] -- Append current season if active
            ELSE y.active_seasons -- Otherwise, use previous active seasons
        END AS active_seasons,
        COALESCE(y.season + 1, t.active_season) AS season -- Determine the current season
    FROM
        yesterday y
        FULL OUTER JOIN today t ON y.player_name = t.player_name -- Join 'yesterday' and 'today' data on player name
)

-- Select and categorize player states based on activity data
SELECT 
    player_name,
    first_active_season,
    last_active_season,
    active_seasons,
    CASE
        WHEN is_active AND last_active_season_previous IS NULL THEN 'New' -- New players entering the league
        WHEN is_active AND season - last_active_season_previous = 1 THEN 'Continued Playing' -- Players continuing from last season
        WHEN is_active AND season - last_active_season_previous > 1 THEN 'Returned from Retirement' -- Players returning after a gap
        WHEN NOT is_active AND season - last_active_season_previous = 1 THEN 'Retired' -- Players who retired after last season
        ELSE 'Stayed Retired' -- Players who remained retired
    END AS player_state,
    season
FROM combined
