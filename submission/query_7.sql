with lebron_james_games as(
select distinct g.game_date_est as game_dates,d.*, case when pts>10 then 1 else 0 end as pts_10
from bootcamp.nba_game_details d
inner join bootcamp.nba_games g
on d.team_id=g.home_team_id 
and d.game_id=g.game_id
where player_name='LeBron James' 
order by game_dates
)
select *,sum(pts_10)over(partition by pts_10 rows between unbounded preceding and current row) 
 from lebron_james_games
