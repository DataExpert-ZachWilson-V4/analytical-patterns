INSERT into saidaggupati.nba_players_tracking 
--previous data CTE
WITH prior_day AS (
    SELECT 
        player_name,
        first_active_season,
        last_active_season,
        active_seasons,
        player_state,
        season
    FROM saidaggupati.nba_players_tracking 
    WHERE season = 1995
),

-- current day data CTE
current_day AS (
    SELECT player_name, MAX(is_active) AS is_active, MAX(current_season) AS active_season 
    FROM bootcamp.nba_players WHERE current_season = 1996
    GROUP BY player_name
),

-- Combine data
combined_data AS (
    SELECT
        COALESCE(p.player_name, c.player_name) AS player_name, 
        COALESCE(p.first_active_season, c.active_season) AS first_active_season,
        p.last_active_season AS last_active_season_p, 
        c.is_active, 
        COALESCE(c.active_season, p.last_active_season) AS last_active_season, 
        CASE
            WHEN p.active_seasons IS NULL THEN ARRAY[c.active_season] 
            WHEN c.active_season IS NULL THEN p.active_seasons 
            WHEN c.active_season IS NOT NULL AND c.is_active THEN p.active_seasons || ARRAY[c.active_season] 
            ELSE p.active_seasons 
        END AS active_seasons,
        COALESCE(p.season + 1, c.active_season) AS season 
    FROM
        prior_day p
        FULL OUTER JOIN current_day c ON p.player_name = c.player_name 
)


SELECT 
    player_name,
    first_active_season,
    last_active_season,
    active_seasons,
    CASE
        WHEN is_active AND last_active_season_p IS NULL THEN 'New' 
        WHEN is_active AND season - last_active_season_p = 1 THEN 'Continued Playing' 
        WHEN is_active AND season - last_active_season_p > 1 THEN 'Returned from Retirement' 
        WHEN NOT is_active AND season - last_active_season_p = 1 THEN 'Retired' 
        ELSE 'Stayed Retired' 
    END AS player_state,
    season
FROM combined_data