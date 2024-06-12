with
ranked as (
    select
        team,
        total_games_won,
        dense_rank() over (order by total_games_won desc) as rn
    from
        sanchit.game_details_dashboard
    where
        team <> 'n/a'
)

select
    team,
    total_games_won,
    rn
from
    ranked
where
    rn = 1
