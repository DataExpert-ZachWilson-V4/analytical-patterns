-- How many games in a row did LeBron James score over 10 points a game?
--
with games as (
    -- take details from games and game_details for player name LeBron James ande filter out with pts >0
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
lag_data as ( --calculate previous value for did_10 using lag function
    select *, lag(did_10,1) over (partition by player_id order by game_date_est) as prev_did_10
    from games
),
streaks as ( -- calculate the streak id
    select 
    player_id,
    player_name,
    game_id,
    pts,
    did_10,
    sum(case when did_10 != prev_did_10 then 1 else 0 end) over (partition by player_id order by game_date_est) as streak_id 

    from lag_data 
    and pts is not null
),
streak_length as ( -- calculate streak length 
    select player_id, 
    player_name, 
    count(1) as streak_length 
    from streaks
    group by player_id, player_name, streak_id 
    having max(did_10) =1
)

select max_by(player_id, streak_length) as player_id,
max_by(player_name, streak_length) as player_name,
max(streak_length) as games_in_a_row_with_score_over_10_pts
from streak_length