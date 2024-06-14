--Query that uses window functions to answer: How many games in a row did LeBron James score over 10 points a 
--gmae?
with nba_games_information as (
  select
    gd.game_id,
    gd.player_name,
    g.game_date_est as game_date,
    gd.pts > 10 as player_scored_over_10
  from bootcamp.nba_game_details_dedup as gd
  inner join bootcamp.nba_games as g
    on gd.game_id = g.game_id
),

lagged_table as (
  select
    *,
    lag(player_scored_over_10, 1) over (
      partition by player_name
      order by game_date
    ) as prev_game_scored_over_10
  from nba_games_information
)

select
  player_name,
  sum(if(
    player_scored_over_10 and prev_game_scored_over_10,
    1,
    0
  )) as consecutive_games_scored_over_10
from lagged_table
where player_name = 'LeBron James'
group by 1