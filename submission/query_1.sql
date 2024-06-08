-- Build a CTE of previous season
with last_season as (
    select * 
    from bootcamp.nba_players
    where current_season = 1999
),
-- CTE for current season
current_season as (
    select * 
    from bootcamp.nba_players
    where current_season = 2000
),
-- CTE for final result
result as (
    select
        coalesce(l.player_name, c.player_name) as player_name,
        CASE
            -- Last season year column is empty + current season is not and seasons cummulative array is empty
            WHEN l.current_season is null and c.current_season is not null and l.seasons is null then 'New'
            -- Last season year is not empty + current season is not empty
            WHEN l.current_season is not null and c.current_season is null then 'Retired'
            -- Last season year is not empty + current season is not empty
            WHEN l.current_season is not null and c.current_season is not null then 'Continued Playing'
            -- Last season year is empty + current season year is not + seasons cumulative array is not empty
            WHEN l.current_season is null and c.current_season is not null and l.seasons is not null then 'Returned from Retirement'
            else 'Stayed Retired'
        END AS change_tracking,
        c.current_season
    from last_season l
    full outer join current_season c
        on c.player_name = l.player_name
)
select 
    *
from result
