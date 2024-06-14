--
--
-- Write a query (query_1) that does state change tracking for nba_players.
-- Create a state change-tracking field that takes on the following values:
--      A player entering the league should be New
--      A player leaving the league should be Retired
--      A player staying in the league should be Continued Playing
--      A player that comes out of retirement should be Returned from Retirement
--      A player that stays out of the league should be Stayed Retired

-- Define the previous season's player data
WITH last_season AS (
    SELECT
        player_name,            -- Player's name
        height,                 -- Player's height
        college,                -- College the player attended
        country,                -- Country of the player
        draft_year,             -- Year the player was drafted
        draft_round,            -- Round in which the player was drafted
        draft_number,           -- Number the player was drafted at
        seasons,                -- Array of player's season statistics
        current_season,         -- Current season being considered for this player
        years_since_last_active -- Number of years since the player was last active
    FROM
        bootcamp.nba_players
    WHERE
        current_season = 1995   -- The previous season data is from 1995
),
-- Define the current season's player data
this_season AS (
    SELECT
        player_name,  -- Player's name
        season,       -- The season being considered (1996)
        college,      -- College the player attended (if applicable)
        country,      -- Country of the player (if applicable)
        draft_year,   -- Year the player was drafted (if applicable)
        draft_round,  -- Round in which the player was drafted (if applicable)
        draft_number, -- Number the player was drafted at (if applicable)
        height,       -- Player's height (if applicable)
        age,          -- Player's age
        weight,       -- Player's weight
        gp,           -- Games played by the player in the season
        pts,          -- Points scored by the player in the season
        reb,          -- Rebounds by the player in the season
        ast           -- Assists by the player in the season
    FROM
        bootcamp.nba_player_seasons
    WHERE
        season = 1996 -- The current season data is from 1996
)
-- Combine the previous and current season data and determine player states
SELECT
    COALESCE(ls.player_name, ts.player_name) AS player_name, -- Use player's name from either season data
    COALESCE(ls.height, ts.height) AS height,                -- Use height from either season data
    COALESCE(ls.college, ts.college) AS college,             -- Use college from either season data
    COALESCE(ls.country, ts.country) AS country,             -- Use country from either season data
    COALESCE(ls.draft_year, ts.draft_year) AS draft_year,    -- Use draft year from either season data
    COALESCE(ls.draft_round, ts.draft_round) AS draft_round, -- Use draft round from either season data
    COALESCE(ls.draft_number, ts.draft_number) AS draft_number, -- Use draft number from either season data
    -- Construct the seasons array based on the available data
    CASE
        WHEN ts.season IS NOT NULL THEN
            ARRAY[ROW(ts.season, ts.age, ts.weight, ts.gp, ts.pts, ts.reb, ts.ast)] || COALESCE(ls.seasons, ARRAY[])
        ELSE
            ls.seasons
    END AS seasons,
    -- Determine if the player is active in the current season
    ts.season IS NOT NULL AS is_active, -- True if the player has current season data, otherwise false
    -- Calculate the years since the player was last active
    CASE
        WHEN ts.season IS NOT NULL THEN 0 -- If the player has current season data, reset the counter
        ELSE COALESCE(ls.years_since_last_active, 0) + 1 -- Otherwise, increment the counter
    END AS years_since_last_active,
    -- Set the current season based on the available data
    COALESCE(ts.season, ls.current_season + 1) AS current_season, -- Use the current season or increment the last season
    -- Determine the player's state based on the season data
    CASE
        WHEN ls.seasons IS NULL AND ts.season IS NOT NULL THEN 'New' -- New player entering the league
        WHEN ts.season IS NULL AND ls.seasons[1][1] = ls.current_season THEN 'Retired' -- Player retired this season
        WHEN ts.season IS NULL AND ls.seasons[1][1] < ls.current_season THEN 'Stayed Retired' -- Player remained retired
        WHEN ts.season IS NOT NULL AND ls.seasons[1][1] = ls.current_season THEN 'Continued Playing' -- Player continued playing
        WHEN ts.season IS NOT NULL AND ls.seasons[1][1] < ls.current_season THEN 'Returned from Retirement' -- Player returned from retirement
        ELSE 'ERROR' -- Catch-all for any unexpected cases
    END AS state
FROM
    last_season ls
    FULL OUTER JOIN this_season ts ON ls.player_name = ts.player_name
ORDER BY
    player_name