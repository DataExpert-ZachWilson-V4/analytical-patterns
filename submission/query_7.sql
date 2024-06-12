with points_threshold as (
    select
        game_date_est,
        case when a.pts > 10 then 1 else 0 end as scored_above_threshold,
        row_number() over (order by game_date_est) as rn
    from
        bootcamp.nba_game_details_dedup as a
    inner join
        bootcamp.nba_games as b
        on
            a.game_id = b.game_id
    where
        player_name = 'lebron james'
),

lagged as (
    select
        rn,
        rn - lag(rn) over (order by rn) as lag_diff
    from
        points_threshold
    where
        scored_above_threshold = 1
),

streak_groups as (
    select
        rn,
        sum(case when lag_diff > 1 then 1 else 0 end)
            over (order by rn)
            as streak_group
    from
        lagged
)

select count(*) as streak_length
from
    streak_groups
group by
    streak_group
order by
    streak_length desc
limit 1
