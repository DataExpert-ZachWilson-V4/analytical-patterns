/* CREATE TABLE hdamerla.state_change_nba_players (
  player_name VARCHAR,
  first_active_season INTEGER,
  last_active_season INTEGER,
  active_seasons ARRAY(INTEGER),
  player_season_state VARCHAR,
  season INTEGER
)
WITH
  (
    FORMAT = 'PARQUET',
    partitioning = ARRAY['season']
  )
  */


Insert into
   hdamerla.state_change_nba_players with yesterday as 
   (
      select
         * 
      from
         hdamerla.state_change_nba_players 
      where
         season = 2001 
   )
,
   today as 
   (
      select
         player_name,
         max(is_active) as is_active,
         max(current_season) AS active_season 
      from
         bootcamp.nba_players 
      where
         current_season = 2002 
      group by
         player_name 
   )
,
   combined as 
   (
      select
         coalesce(y.player_name, t.player_name) as player_name,
         coalesce(y.first_active_season, t.active_season) as first_active_season,
         y.last_active_season as last_active_season_previous,
         coalesce(t.active_season, y.last_active_season) as last_active_season,
         t.is_active as is_active,
         case
            when
               y.active_seasons is null 
            then
               ARRAY[t.active_season] 
            when
               t.active_season is null 
            then
               y.active_seasons 
            when
               t.active_season is not null 
               and t.is_active 
            then
               y.active_seasons || ARRAY[t.active_season] 
            else
               y.active_seasons 
         end
         as active_seasons, coalesce(y.season + 1, t.active_season) as season 
      from
         yesterday y 
         full outer join
            today t 
            on y.player_name = t.player_name 
   )
   select
      player_name,
      first_active_season,
      last_active_season,
      active_seasons,
      case
         when
            is_active 
            and last_active_season_previous is null 
         then
            'New' 
         when
            is_active 
            and season - last_active_season_previous = 1 
         then
            'Continued Playing' 
         when
            is_active 
            and season - last_active_season_previous > 1 
         then
            'Returned from Retirement' 
         when
            not is_active 
            and season - last_active_season_previous = 1 
         then
            'Retired' 
         else
            'Stayed Retired' 
      end
      as player_season_state, season 
   from
      combined
