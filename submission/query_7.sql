with games as (
    select distinct ng.game_date_est,
           ngd.player_id, 
           ngd.player_name,
           ngd.game_id,
           ngd.pts,
        case when ngd.pts >10 then 1
             else 0 end as did_10
    from bootcamp.nba_game_details ngd 
    join bootcamp.nba_games ng 
    on ngd.game_id = ng.game_id
    where ngd.player_name = 'LeBron James'
    and ngd.pts > 0
),
lag_data as (
    select *, lag(did_10,1) over (partition by player_id order by game_date_est) as prev_did_10
    from games
),
streaks as (
    select 
    player_id,
    player_name,
    game_id,
    pts,
    did_10,
    sum(case when did_10 != prev_did_10 then 1 else 0 end) over (partition by player_id order by game_date_est) as streak_id 
    from lag_data 
),
streak_length as (
    select player_id, 
    player_name, 
    count(1) as streak_length 
    from streaks
    group by player_id, player_name, streak_id having max(did_10) =1
)

select max_by(player_id, streak_length) as player_id,
max_by(player_name, streak_length) as player_name,
max(streak_length) as games_in_a_row_with_score_over_10_pts
from streak_length