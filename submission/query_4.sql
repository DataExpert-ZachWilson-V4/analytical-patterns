with
ranked as (
    select
        player_name,
        season,
        total_player_points,
        dense_rank() over (order by total_player_points desc) as rn
    from
        sanchit.game_details_dashboard
    where
        player_name is not null
        and
        season is not null
        and
        total_player_points is not null
)

select
    player_name,
    season,
    total_player_points
from
    ranked
where
    rn = 1
