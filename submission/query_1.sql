
Insert into raj.nba_players_state_tracking
With last_season as (
Select * from raj.nba_players_state_tracking
where season = 1998
), 
current_season_cte as (
Select player_name,
MAX(is_active) as is_active,
MAX(current_season) as current_season 
from  bootcamp.nba_players
where current_season = 1999
Group By player_name
), 
final as (
Select 
COALESCE(l.player_name, c.player_name) as player_name,
COALESCE(l.first_active_season,c.current_season) as first_active_season,
COALESCE(c.current_season,l.first_active_season) as last_active_season,
CASE WHEN
l.seasons_active IS NULL THEN ARRAY[c.current_season]
WHEN c.current_season IS NULL THEN l.seasons_active
ELSE
l.seasons_active || ARRAY[c.current_season]
END AS seasons_active,
COALESCE(l.season+1, c.current_season) AS season,
c.is_active
from last_season l 
full outer join current_season_cte c on l.player_name = c.player_name
)
Select  player_name, first_active_season, last_active_season, seasons_active,
CASE 
WHEN is_active and (first_active_season - last_active_season) = 0 THEN 'new'
WHEN is_active and (season - last_active_season) = 1 THEN 'Continued Playing'
WHEN is_active and (season - last_active_season) > 1 THEN 'Returned from Retirement'
WHEN NOT is_active and (season - last_active_season) = 1 THEN 'Retired'
ELSE 'Stayed Retired'
END AS player_state,
season
from final







