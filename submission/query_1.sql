-- Setup - Create the state tracking table:
-- create
-- or replace table sarneski44638.nba_players_state_tracking (
--     player_name VARCHAR,
--     player_state VARCHAR,
--     current_season INTEGER
-- )
-- WITH
--     (
--         FORMAT = 'PARQUET',
--         partitioning = ARRAY['current_season']
--     )
-- Incremental query to track state: (vary @year from 1995 -> 2021 based on date in nba_player_season table)
insert into
    sarneski44638.nba_players_state_tracking
with
    last_season as (
        select
            player_name,
            player_state,
            current_season
        from
            sarneski44638.nba_players_state_tracking
        where
            current_season = 1995 -- @year
    ),
    current_season as (
        select
            player_name,
            season
        from
            bootcamp.nba_player_seasons
        where
            season = 1996 -- @year + 1
    )
select
    coalesce(l.player_name, c.player_name) as player_name,
    case
        when l.player_name is null then 'New'
        when l.player_state = 'Retired'
        and c.player_name is null then 'Stayed Retired'
        when l.player_state = 'Stayed Retired'
        and c.player_name is null then 'Stayed Retired'
        when l.player_state in ('Retired', 'Stayed Retired')
        and c.player_name is not null then 'Returned from Retirement'
        when l.player_state is not null
        and c.player_name is null then 'Retired'
        when l.player_state in (
            'New',
            'Continued Playing',
            'Returned from Retirement' -- once player has returned from retirement and played for another year they are considered Continued Playing
        )
        and c.player_name is not null then 'Continued Playing'
    end as player_state,
    coalesce(l.current_season + 1, c.season) as current_season
from
    last_season as l
    full outer join current_season c on c.player_name = l.player_name