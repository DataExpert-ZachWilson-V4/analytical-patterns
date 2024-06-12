-- Write a query (query_2) that uses GROUPING SETS to perform aggregations of the nba_game_details data.
-- Create slices that aggregate along the following combinations of dimensions:
--
-- player and team
-- player and season
-- team
--
-- CREATE TABLE jlcharbneau.nba_grouping_sets (
--     aggregation_level   VARCHAR,
--     player_name         VARCHAR,
--     team_abbreviation   VARCHAR,
--     season              VARCHAR,
--     total_points        DOUBLE,
--     total_rebounds      DOUBLE,
--     total_assists       DOUBLE,
--     player_wins         BIGINT,
--     team_wins           BIGINT
-- )
-- WITH (
--     format = 'PARQUET',
--     format_version = 2,
--     location = 's3://zachwilsonsorganization-522/ce557692-2f28-41e8-8250-8608042d2acb/8ada082a-be6f-4fd3-997b-c00eb68297b4'
-- )
--
insert into jlcharbneau.nba_grouping_sets
-- Deduplicating nba_game_details table to ensure unique player entries per game
WITH nba_game_details_full AS (
    SELECT *,
        -- Using ROW_NUMBER to identify duplicate player entries per game
        ROW_NUMBER() OVER (PARTITION BY game_id, team_id, player_id) AS row_number
    FROM academy.bootcamp.nba_game_details
),

-- Keeping only the first occurrence of each player entry per game
nba_game_details_deduped AS (
    SELECT *,
        -- Using ROW_NUMBER to identify the primary player entry for ordering within each team-game combination
        ROW_NUMBER() OVER (PARTITION BY team_id, game_id ORDER BY player_name) AS player_order
    FROM nba_game_details_full
    WHERE row_number = 1 -- Filtering to keep only the first entry
),

-- Deduplicating nba_games table to ensure unique game entries
nba_games_full AS (
    SELECT
        game_id,
        season,
        team_id_home,
        home_team_wins,
        -- Using ROW_NUMBER to identify duplicate game entries
        ROW_NUMBER() OVER (PARTITION BY game_id) AS row_number
    FROM academy.bootcamp.nba_games
),

-- Keeping only the first occurrence of each game entry
nba_games_deduped AS (
    SELECT
        game_id,
        season,
        team_id_home,
        home_team_wins
    FROM nba_games_full
    WHERE row_number = 1 -- Filtering to keep only the first entry
)

-- Performing aggregations using GROUPING SETS
SELECT
    -- Determine the aggregation level based on the GROUPING function
    CASE
        WHEN GROUPING(GD.player_name, GD.team_abbreviation) = 0 THEN 'player_team'
        WHEN GROUPING(GD.player_name, G.season) = 0 THEN 'player_season'
        WHEN GROUPING(GD.team_abbreviation) = 0 THEN 'team'
    END as aggregation_level,

    -- Handle null values using COALESCE
    COALESCE(GD.player_name, '(overall)') AS player_name,
    COALESCE(GD.team_abbreviation, '(overall)') AS team_abbreviation,
    COALESCE(CAST(G.season AS VARCHAR), '(overall)') AS season,

    -- Aggregate statistics
    SUM(GD.pts) AS total_points,
    SUM(GD.reb) AS total_rebounds,
    SUM(GD.ast) AS total_assists,

    -- Calculate player wins based on team and game results
    SUM(
        CASE
            WHEN GD.team_id = G.team_id_home THEN G.home_team_wins
            ELSE 1 - G.home_team_wins
        END
    ) AS player_wins,

    -- Calculate team wins at the team level, ensuring no duplication
    SUM(
        CASE
            WHEN GD.player_order = 1 THEN CASE WHEN GD.team_id = G.team_id_home THEN G.home_team_wins ELSE 1 - G.home_team_wins END
        END
    ) AS team_wins

FROM
    nba_game_details_deduped AS GD
    JOIN nba_games_deduped AS G ON GD.game_id = G.game_id

-- Define GROUPING SETS for aggregations
GROUP BY GROUPING SETS (
    (GD.player_name, GD.team_abbreviation), -- Group by player and team
    (GD.player_name, G.season), -- Group by player and season
    (GD.team_abbreviation) -- Group by team
)
