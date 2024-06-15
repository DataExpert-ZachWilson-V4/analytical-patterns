-- Write a query (`query_1`) that does state change tracking for `nba_players`.
-- Create a state change-tracking field that takes on the following values:
--   - A player entering the league should be `New`
--   - A player leaving the league should be `Retired`
--   - A player staying in the league should be `Continued Playing`
--   - A player that comes out of retirement should be `Returned from Retirement`
--   - A player that stays out of the league should be `Stayed Retired`

-- create or replace table shabab.nba_players_track(
--     player_name varchar,
--     college varchar,
--     country varchar,
--     draft_year varchar,
--     draft_round	varchar,
--     draft_number varchar,
--     seasons array(row(season integer, age integer, weight integer, gp integer, pts double, reb double, ast double)),
--     is_active boolean,
--     years_since_last_active integer,
--     current_season integer,
--     state_change varchar
-- ) with (
--     format = 'PARQUET', partitioning = ARRAY['current_season']
-- )

-- insert into shabab.nba_players_track
with
    last_season as (
        select
            player_name,
            height,
            college,
            country,
            draft_year,
            draft_round,
            draft_number,
            seasons,
            current_season,
            years_since_last_active
        from bootcamp.nba_players where current_season = 1995
    ),
    this_season as (
        select
            player_name,
            season,
            college,
            country,
            draft_year,
            draft_round,
            draft_number,
            height,
            age,
            weight,
            gp,
            pts,
            reb,
            ast
        from bootcamp.nba_player_seasons where season = 1996
    )
select
    COALESCE(ls.player_name, ts.player_name) as player_name,
    COALESCE(ls.college, ts.college) as college,
    COALESCE(ls.country, ts.country) as country,
    COALESCE(ls.draft_year, ts.draft_year) as draft_year,
    COALESCE(ls.draft_round, ts.draft_round) as draft_round,
    COALESCE(ls.draft_number, ts.draft_number) as draft_number,

    -- seasons array
    case
        when ts.season is not NULL
            then array[row(ts.season, ts.age, ts.weight, ts.gp, ts.pts, ts.reb, ts.ast)] || COALESCE(ls.seasons, array[])
        else
            ls.seasons
    end as seasons,

    --is_active?
    ts.season is not NULL as is_active,

    -- years since the player was last active
    case
        when ts.season is not NULL
            then 0 -- If the player has current season data, reset the counter
        else
            ls.years_since_last_active + 1 -- Otherwise, increment the counter
    end as years_since_last_active,

    -- current season based on the available data
    COALESCE(ts.season, ls.current_season + 1) as current_season,

    -- player's state change
    case
        -- no prev records; appear in this season
        when ts.season is not NULL and ls.seasons is NULL
            then 'new'
        -- has prev records; but does not appear this season
        when ls.seasons[1][1] = ls.current_season and ts.season is NULL
            then 'retired'
        -- has prev records; appears this season
        when ls.seasons[1][1] = ls.current_season and ts.season is not NULL
            then 'continued_playing'
        when ts.season is not NULL and ls.seasons[1][1] < ls.current_season
            then 'returned_from_retirement'
        when ls.seasons[1][1] < ls.current_season and ts.season is NULL
            then 'stayed_retired'
    end as state_change
from last_season ls full outer join this_season ts
    on ls.player_name = ts.player_name
