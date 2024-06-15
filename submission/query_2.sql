-- - Write a query (`query_2`) that uses `GROUPING SETS` to perform aggregations of the `nba_game_details` data.
-- Create slices that aggregate along the following combinations of dimensions:
--   - player and team
--   - player and season
--   - team
-- Note: credit to jc taking me in a different direction here

-- create or replace table shabab.nba_grouping_sets (
--     aggregation_level   varchar,
--     player_name         varchar,
--     team_abbreviation   varchar,
--     season              varchar,
--     total_points        double,
--     total_rebounds      double,
--     total_assists       double,
--     player_wins         bigint,
--     team_wins           bigint
-- ) with (
--     format = 'PARQUET',
--     format_version = 2
-- )
--
-- insert into shabab.nba_grouping_sets

with
    -- ROW_NUMBER to fetch duplicate player entries per game
    nba_game_details_full as (
        select *,
            ROW_NUMBER() over (partition by game_id, team_id, player_id) as row_number
        from bootcamp.nba_game_details
    ),
    -- de-duplicating nba_game_details; keep first and unique player entry per game
    nba_game_details_deduped as (
        select *,
            -- using ROW_NUMBER to identify the primary player entry for ordering within each team-game combination
            ROW_NUMBER() over (partition by team_id, game_id order by player_name) as player_order
        from nba_game_details_full
        where row_number = 1 -- filter on first and unique entry
    ),
    -- fetch de-duped nba_games records
    nba_games_full as (
        select
            game_id,
            season,
            team_id_home,
            home_team_wins,
            -- using ROW_NUMBER to identify duplicate game entries
            ROW_NUMBER() over (partition by game_id) as row_number
        from bootcamp.nba_games
    ),
    nba_games_deduped as (
        select
            game_id,
            season,
            team_id_home,
            home_team_wins
        from nba_games_full
        where row_number = 1 -- filtering to keep only the first entry
    )

-- aggregations using GROUPING SETS
select
    -- determine the aggregation level via GROUPING function
    case
        when GROUPING(gd.player_name, gd.team_abbreviation) = 0 then 'player_team'
        when GROUPING(gd.player_name, g.season) = 0 then 'player_season'
        when GROUPING(gd.team_abbreviation) = 0 then 'team'
    end as aggregation_level,

    -- COALESCE null values
    COALESCE(gd.player_name, '(overall)') AS player_name,
    COALESCE(gd.team_abbreviation, '(overall)') AS team_abbreviation,
    COALESCE(CAST(g.season AS varchar), '(overall)') AS season,

    -- aggregate statistics
    SUM(gd.pts) AS total_points,
    SUM(gd.reb) AS total_rebounds,
    SUM(gd.ast) AS total_assists,

    -- calculate player wins, based on team and game results
    SUM(
        case
            when gd.team_id = g.team_id_home
                then g.home_team_wins
            else
                1 - g.home_team_wins
        end
    ) as player_wins,

    -- calculate team wins at the team level
    SUM(
        case
            when gd.player_order = 1
                then case
                    when gd.team_id = g.team_id_home then g.home_team_wins else 1 - g.home_team_wins
                    end
        end
    ) as team_wins

from
    nba_game_details_deduped gd join nba_games_deduped g
        on gd.game_id = g.game_id

-- define GROUPING SETS
group by GROUPING SETS (
    (gd.player_name, gd.team_abbreviation), -- group by player and team
    (gd.player_name, g.season), -- group by player and season
    (gd.team_abbreviation) -- group by team
)
