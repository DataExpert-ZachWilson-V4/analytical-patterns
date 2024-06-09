with nba_games_data as (
  select distinct
    gd.game_id,
    gd.team_abbreviation,
    g.game_date_est as game_date,
    if(
      (gd.team_id = g.home_team_id and g.home_team_wins = 1)
      or (gd.team_id = g.visitor_team_id and g.home_team_wins = 0),
      1,
      0
    ) as wins
  from bootcamp.nba_game_details_dedup as gd
  inner join bootcamp.nba_games as g
    on gd.game_id = g.game_id
),

streak as (
  select
    *,
    sum(wins) over (
      partition by team_abbreviation
      order by game_date
      rows between 89 preceding and current row
    ) as ninety_day_win_streak
  from nba_games_data
)

select
  team_abbreviation as team,
  max_by(game_date, ninety_day_win_streak) as end_stretch_date,
  max(ninety_day_win_streak) as wins_90_days_stretch
from streak
group by 1
order by 3 desc, 2 desc
