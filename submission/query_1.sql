Insert into Jaswanthv.nba_players_track_status
With last_season As
(Select 
	player_name,
	first_active_season,
	last_active_season,
	seasons_active,
	season_active_state,
	season
from Jaswanthv.nba_players_track_status
where season = 1995
),
current_season As
(
Select
  player_name,
  Max(seasons[1][1]) As last_active_season, -- Fetching the last active season
  MAX(is_active) As is_active,
  MAX(current_season) As season
from bootcamp.nba_players
Where current_season = 1996
Group By player_name
)
,Pre_load As(Select
  COALESCE(ls.player_name, cs.player_name) As player_name,
  COALESCE(ls.first_active_season, cs.last_active_season) As first_active_season,
  COALESCE(cs.last_active_season,ls.last_active_season ) As last_active_season,
  CASE 
    WHEN ls.seasons_active IS NULL Then ARRAY[cs.last_active_season]
    WHEN cs.last_active_season IS NULL Then ls.seasons_active
	WHEN cs.last_active_season = ls.seasons_active[1] Then ls.seasons_active -- If last_active_season doesn't change keeping the array same so as to not add duplicate value in Array
    Else  ARRAY[cs.last_active_season] || ls.seasons_active
    End As seasons_active,
  CASE
    WHEN ls.player_name IS NULL And cs.player_name Is NOT NULL Then 'New'
    WHEN cs.is_active And (cs.season - ls.last_active_season) = 1 Then 'Continued Playing'
	WHEN NOT cs.is_active And (cs.season - ls.last_active_season) = 1 Then 'Retired'
    WHEN cs.is_active And (cs.season - ls.last_active_season) > 1 Then 'Returned from Retirement'
    Else 'Stayed Retired' End As season_active_state,
  COALESCE(cs.season,ls.season + 1) As  season
From last_season ls FULL OUTER JOIN current_season cs on ls.player_name = cs.player_name)
Select 
  player_name,
  first_active_season,
  last_active_season,
  seasons_active,
  season_active_state,
  season
From Pre_load
