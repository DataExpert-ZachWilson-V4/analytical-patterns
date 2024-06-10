--most games a single team has won in a given 90-game stretch
with deduped_data as (
    -- take distinct rows
    select distinct  
    game_date_est, 
    game_id,
    home_team_id,
    visitor_team_id,
    home_team_wins
    from bootcamp.nba_games
   
),
combined as (
    --create combined data for each team
    select game_date_est as game_date,
    home_team_id as team_id,
    home_team_wins as did_win
    from deduped_data
    union
    select game_date_est as game_date,
    home_team_id as team_id,
    case when home_team_wins = 0 then 1
         when home_team_wins = 1 then 0 end as did_win
    from deduped_data
),
given_90_game_stretch as (
    --90 day sliding window & calculate total wins
    select 
    team_id, 
    game_date - INTERVAL '90' DAY as starting,
    game_date as ending, 
    sum(did_win) over (partition by team_id order by game_date
                        ROWS BETWEEN 89 PRECEDING AND CURRENT ROW) as tot_wins
    from combined
)
select 
max_by(starting, tot_wins) as starting_window, 
max_by(ending, tot_wins) as ending_window, 
max_by(team_id, tot_wins) as team_id,
max(tot_wins) as given_90_game_stretch
from given_90_game_stretch