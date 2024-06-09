insert into dennisgera.nba_players_state_tracking
with last_season as (
  select *
  from dennisgera.nba_players_state_tracking
  where season = 1995
),

current_season as (
  select
    player_name,
    is_active,
    current_season
  from bootcamp.nba_players
  where current_season = 1996
),

combined as (
  select -- noqa: disable=RF02
    ls.last_active_season as previous_last_active_season,
    cs.is_active,
    coalesce(ls.player_name, cs.player_name) as player_name,
    coalesce(
      ls.first_active_season, if(cs.is_active, cs.current_season, null)
    ) as first_active_season,
    coalesce(if(cs.is_active, cs.current_season, null), ls.last_active_season)
      as last_active_season,
    case
      when
        ls.seasons_active is null and cs.is_active
        then array[cs.current_season]
      when
        ls.seasons_active is not null
        and (not cs.is_active or cs.is_active is null)
        then ls.seasons_active
      when
        ls.seasons_active is not null and cs.is_active
        then ls.seasons_active || array[cs.current_season]
    end as seasons_active,
    coalesce(cs.current_season, ls.season + 1) as season
  from last_season as ls
  full join current_season as cs
    on ls.player_name = cs.player_name
),

final as (
  select
    player_name,
    first_active_season,
    last_active_season,
    seasons_active,
    case
      when season - first_active_season = 0 then 'New'
      when season - previous_last_active_season = 1 then 'Continued Playing'
      when
        is_active and season - previous_last_active_season > 1
        then 'Returned from Retirement'
      when
        not is_active and season - previous_last_active_season = 1
        then 'Retired'
      else 'Stayed Retired'
    end as yearly_active_state,
    season
  from combined
)

select *
from final
