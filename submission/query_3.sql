with
ranked as (
    select
        player_name,
        team,
        total_player_points,
        dense_rank() over (order by total_player_points desc) as rn
    from
        sanchit.game_details_dashboard
    where
        team <> 'n/a'
        and
        player_name is not null
)

select
    player_name,
    team,
    total_player_points
from
    ranked
where
    rn = 1
